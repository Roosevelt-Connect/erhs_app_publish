import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:ui' as ui; // You might be able to REMOVE this if platformViewRegistry was its only use here
import '../../platform_web_interop.dart' as platform_interop;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

final logger = Logger();

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  late Animation<Alignment> _topLeftAlignmentAnimation1;
  late Animation<Alignment> _bottomRightAlignmentAnimation1;

  String emailToQuery = "";
  String code = "";
  Map<String, dynamic>? userData;

  String? _scanBarcodeResult;

  bool _dialogShowing = false; // Ensure this is a class member
  // Timer? _autoDismissTimer; // REMOVE THIS LINE

  // Initial Selected Value
  String dropdownValue = 'Attendance Check-In';
  // List of items in our dropdown menu
  var items = [
    'Attendance Check-In',
    'Attendance Check-Out',
    'Off-Campus Check-In',
    'Off-Campus Check-Out',
    'Event Check-In',
    'Event Check-Out',
  ];

  int _counter = 0; // This is the variable to increase
  late Timer _timer; // Timer for periodic updates

  String? selectedOption;
  bool isOffCampusSelected = false;
  String? selectedLunch;

  // ADD THESE FOR WEB SCANNER
  bool _isWebScannerVisible = false;
  final String _webScannerViewType = 'web-scanner-video-view';
  // CHANGE the type to use the facade
  late platform_interop.VideoElement _webVideoElement;

  // ADD THESE FOR PHYSICAL SCANNER
  bool _isPhysicalScannerModeActive = false;
  final FocusNode _keyboardFocusNode = FocusNode();
  String _keyboardInputBuffer = '';
  DateTime? _scannerInputStartTime; // Time when the first char of a potential scan was received
  DateTime? _lastCharInputTime;   // Time when the last char was received
  // Thresholds for scanner input detection
  final Duration _maxInterCharDelay = const Duration(milliseconds: 100); // Max delay between chars for it to be considered a continuous scan
  final Duration _maxTotalScanTime = const Duration(milliseconds: 1000); // Max total time for a complete scan input including Enter
  final int _minScanLength = 6; // Minimum length for a string to be considered a valid scan

  @override
  void initState() {
    super.initState();
    // Set up a timer to update the counter every second
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _counter++;
      });
    });

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      )
    ]).animate(_animationController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      )
    ]).animate(_animationController);

    _topLeftAlignmentAnimation1 = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.center, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.center),
        weight: 1,
      )
    ]).animate(_animationController);

    _bottomRightAlignmentAnimation1 = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.center, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.center),
        weight: 1,
      )
    ]).animate(_animationController);

    _animationController.repeat();

    // ADD THIS FOR WEB SCANNER
    if (kIsWeb) {
      // Use the facade for VideoElement
      _webVideoElement = platform_interop.VideoElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true');

      // Register the view factory for the web video element using the facade
      platform_interop.registerViewFactory(
        _webScannerViewType,
        _webVideoElement,
      );

      // Set up JS interop callbacks on the global window object
      platform_interop.setProperty(
        platform_interop.globalThis,
        '_flutterWebScanResultCallback', // Correct callback name
        platform_interop.allowInterop(_handleWebScanResultFromJs),
      );
      platform_interop.setProperty(
        platform_interop.globalThis,
        '_flutterWebScanErrorCallback',
        platform_interop.allowInterop(_handleWebScanErrorFromJs),
      );
    }
    // Request focus if physical scanner mode is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isPhysicalScannerModeActive) {
        FocusScope.of(context).requestFocus(_keyboardFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    _keyboardFocusNode.dispose(); // Dispose the FocusNode
    // _autoDismissTimer?.cancel(); // REMOVE THIS LINE

    if (kIsWeb && _isWebScannerVisible) {
      // Use the facade for JS interop calls
      platform_interop.callMethod(platform_interop.globalThis, 'stopWebScanner', []);
    }

    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (!_isPhysicalScannerModeActive) return; // Only process if physical scanner mode is active

    if (event is RawKeyDownEvent) {
      final now = DateTime.now();

      if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        bool isValidScan = false;
        if (_keyboardInputBuffer.isNotEmpty &&
            _keyboardInputBuffer.length >= _minScanLength &&
            _scannerInputStartTime != null &&
            _lastCharInputTime != null) {
          
          final totalDuration = now.difference(_scannerInputStartTime!);
          final timeSinceLastChar = now.difference(_lastCharInputTime!);

          // Check if 'Enter' came quickly after the last character AND total scan time is reasonable
          if (timeSinceLastChar < _maxInterCharDelay && totalDuration < _maxTotalScanTime) {
            isValidScan = true;
          } else {
            logger.i(
                "Physical scan rejected: Enter too slow (since last char: ${timeSinceLastChar.inMilliseconds}ms) or total time too long (total: ${totalDuration.inMilliseconds}ms). Buffer: $_keyboardInputBuffer");
          }
        } else {
           logger.i(
               "Physical scan rejected: Buffer empty (len: ${_keyboardInputBuffer.length}), too short (min: $_minScanLength), or timing info missing. Buffer: $_keyboardInputBuffer");
        }

        if (isValidScan) {
          logger.i("Physical scanner input accepted: $_keyboardInputBuffer");
          final String scannedCode = _keyboardInputBuffer; // Copy before clearing
          _foundBarcode(scannedCode); 
          if (mounted) {
            setState(() {
              _scanBarcodeResult = scannedCode; 
            });
          }
        } else {
          // If not a valid scan, but enter was pressed, we still clear the buffer.
          if (_keyboardInputBuffer.isNotEmpty) {
              logger.i("Manual input or invalid scan rejected on Enter: $_keyboardInputBuffer");
          }
        }
        // Reset for next scan attempt
        _keyboardInputBuffer = '';
        _scannerInputStartTime = null;
        _lastCharInputTime = null;

      } else if (event.character != null && event.character!.isNotEmpty) {
        // Consider only printable ASCII characters, typical for many scanners
        if (event.character!.length == 1 && event.character!.codeUnitAt(0) >= 32 && event.character!.codeUnitAt(0) <= 126) {
          // Check for inter-character delay. If too long, reset current buffer.
          if (_lastCharInputTime != null && now.difference(_lastCharInputTime!) > _maxInterCharDelay) {
            logger.i(
                "Physical scan input stream reset due to inter-character delay (${now.difference(_lastCharInputTime!).inMilliseconds}ms). Old buffer: $_keyboardInputBuffer");
            _keyboardInputBuffer = ''; 
            _scannerInputStartTime = null; 
          }

          if (_keyboardInputBuffer.isEmpty) {
            _scannerInputStartTime = now; // Mark start of new potential scan
          }
          _keyboardInputBuffer += event.character!;
          _lastCharInputTime = now;
          // logger.d("Char added: ${event.character}, Buffer: $_keyboardInputBuffer");
        }
      }
    }
  }

  void _toggleScannerMode() {
    setState(() {
      _isPhysicalScannerModeActive = !_isPhysicalScannerModeActive;
      _keyboardInputBuffer = ''; // Clear buffer when switching modes

      if (_isPhysicalScannerModeActive) {
        // Switched TO physical scanner mode
        if (kIsWeb && _isWebScannerVisible) {
          platform_interop.callMethod(platform_interop.globalThis, 'stopWebScanner', []);
          _isWebScannerVisible = false; 
        }
        _scanBarcodeResult = "Physical Scanner Active";
        // Request focus for the keyboard listener
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FocusScope.of(context).requestFocus(_keyboardFocusNode);
          }
        });
      } else {
        // Switched TO camera scanner mode
        _scanBarcodeResult = "Camera Scanner Active";
        // Optionally unfocus, though the active check in _handleKeyPress is key
        // _keyboardFocusNode.unfocus(); 
      }
    });
  }

  Future<Map<String, dynamic>> _queryUserByEmail(String email) async {
    final firestore = FirebaseFirestore.instance;

    // Regex to match digits before the @ symbol
    RegExp regExp = RegExp(r'^(\d+)@');
    Match? match = regExp.firstMatch(email);

    int studentIdNumber = 0; // Initialize with a default value

    if (match != null) {
      String numbers = match.group(1)!; // Extract the matched digits
      studentIdNumber = int.parse(numbers);
    } else {
      logger.w('No match found for student ID in email: $email');
      return {};
    }

    // Get the current date and time
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // Check if tardy
    bool tardy = false;
    final DateFormat formatter = DateFormat('EEEE');
    final String weekday = formatter.format(now);
    int hour = now.hour;
    int minute = now.minute;
    int minutes = hour * 60 + minute;

    if (dropdownValue.contains("Attendance Check-In")) {
      if (weekday == "Wednesday") {
        if (minutes > 590) tardy = true; // After 9:50 AM
      } else {
        if (minutes > 510) tardy = true; // After 8:30 AM
      }
    } else if (dropdownValue.contains("Off-Campus Check-In")) {
      if (selectedLunch == null) {
        logger.w("Off-Campus Check-In attempted without selecting lunch.");
        // Potentially show a dialog or prevent further action
      } else if (weekday == "Wednesday") {
        if (selectedLunch!.contains("1st lunch") && minutes > 728) tardy = true; // After 12:08 PM
        if (selectedLunch!.contains("2nd lunch") && minutes > 780) tardy = true; // After 1:00 PM
      } else if (weekday == "Monday" || weekday == "Tuesday") {
        if (selectedLunch!.contains("1st lunch") && minutes > 739) tardy = true; // After 12:19 PM
        if (selectedLunch!.contains("2nd lunch") && minutes > 807) tardy = true; // After 1:27 PM
      } else { // Thursday, Friday
        if (selectedLunch!.contains("1st lunch") && minutes > 754) tardy = true; // After 12:34 PM
        if (selectedLunch!.contains("2nd lunch") && minutes > 820) tardy = true; // After 1:40 PM
      }
    }

    final documentData = {
      'student_id': studentIdNumber,
      'timestamp': formattedDateTime,
      'purpose': dropdownValue,
      'tardy': tardy,
      'approved': false,
    };

    try {
      await firestore.collection('student_check-in_datalogs').add(documentData);
      logger.i('Document added successfully for $email / $studentIdNumber');
    } catch (e) {
      logger.e('Error adding document: $e');
    }

    // Everything down here queries the email data
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userDataFromDb = userDoc.data() as Map<String, dynamic>;
        return userDataFromDb;
      } else {
        logger.e('No user found with email $email');
        return {};
      }
    } catch (e) {
      logger.e('Error querying user by email: $e');
      return {};
    }
  }

  // Helper method to actually show the dialog is now merged into _showDialog
  // void _performShowDialogActual(String message, Color color) { ... } // REMOVED

// bool _dialogShowing = false; // This is now a class member

Future<void> _showDialog(String message, Color color) async {
  // If a dialog is already showing, dismiss it first
  if (_dialogShowing) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await Future.delayed(const Duration(milliseconds: 100)); 
  }

  _dialogShowing = true;

  // Attempt to give focus back to the keyboard listener *after* this dialog is shown.
  // This allows new scans to be processed while this dialog is visible.
  if (_isPhysicalScannerModeActive && mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This callback runs after the frame where showDialog likely built the dialog.
      // Check _dialogShowing again, as the dialog might have been quickly
      // dismissed by another rapid scan before this callback runs.
      if (mounted && _isPhysicalScannerModeActive && _dialogShowing) {
        FocusScope.of(context).requestFocus(_keyboardFocusNode);
        // logger.i("Attempted to return focus to keyboard node while dialog is visible.");
      }
    });
  }

  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false, // User must explicitly dismiss or new scan will dismiss
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        content: Text(
          message,
          style: TextStyle(color: color, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actions: [ 
          TextButton(
            autofocus: false, // Prevent the button from initially grabbing focus
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              // No need to set _dialogShowing = false here,
              // the block after await showDialog handles it.
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );

  // This block runs after the dialog is popped (either by "OK" or by a new scan dismissing it)
  if (mounted) {
    // This specific dialog instance is now gone.
    // If a new dialog replaced it, that new dialog's _showDialog call would have set _dialogShowing = true again.
    // So, this correctly reflects that *this* dialog instance is no longer active.
    _dialogShowing = false; 
  }

  // If in physical scanner mode, re-focus the keyboard listener.
  // This is crucial if the dialog was dismissed manually (e.g., by "OK")
  // to prepare for the next scan.
  if (_isPhysicalScannerModeActive && mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isPhysicalScannerModeActive) {
        // Only refocus if a dialog isn't currently being shown by a new, superseding call.
        // However, the _dialogShowing check might be tricky here due to async nature.
        // The primary goal is to ensure focus if the page is now dialog-free.
        FocusScope.of(context).requestFocus(_keyboardFocusNode);
        // logger.i("Refocused _keyboardFocusNode after dialog was dismissed.");
      }
    });
  }
}


  void _foundBarcode(String barcodeCap) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    if (dropdownValue == "Event Check-In" || dropdownValue == "Off-Campus Check-Out") {
      try {
        var studentId = int.parse(barcodeCap);

        DocumentSnapshot eventDoc = await firestore
            .collection('event_participants')
            .doc('approved_ids')
            .get();

        if (eventDoc.exists) {
          List<dynamic> approvedIds = (eventDoc.data() as Map<String, dynamic>)['ids'] ?? [];
          final bool isApproved = approvedIds.contains(studentId);
          bool tardy = false;

          final documentData = {
            'student_id': studentId,
            'timestamp': formattedDateTime,
            'purpose': dropdownValue,
            'tardy': tardy,
            'approval': isApproved,
          };

          await firestore
              .collection('student_check-in_datalogs')
              .add(documentData);

          if (isApproved) {
            _showDialog(
                "$barcodeCap is approved for $dropdownValue", Colors.green); // Removed autoDismissDuration
          } else {
            _showDialog("$barcodeCap is denied for $dropdownValue", Colors.red); // Removed autoDismissDuration
          }
        } else {
          _showDialog("Error: Approved IDs document not found", Colors.red); // Removed autoDismissDuration
        }
      } catch (e) {
        if (e is FormatException) {
          _showDialog(
              "Invalid barcode format for Student ID: $barcodeCap", Colors.red); // Removed autoDismissDuration
        } else {
          _showDialog(
              "Error checking approval for $dropdownValue: $e", Colors.red); // Removed autoDismissDuration
        }
      }
    } else if (dropdownValue == "Off-Campus Check-In") {
      try {
        var studentId = int.parse(barcodeCap);
        bool tardy = false;
        final DateFormat formatter = DateFormat('EEEE');
        final String weekday = formatter.format(now);
        int hour = now.hour;
        int minute = now.minute;
        int minutes = hour * 60 + minute;

        if (selectedLunch == null) {
          _showDialog("Error: Please select a lunch period for Off-Campus Check-In.", Colors.red); // Removed autoDismissDuration
          return;
        }

        if (weekday == "Wednesday") {
            if (selectedLunch!.contains("1st lunch") && minutes > 728) {
              tardy = true;
            } else if (selectedLunch!.contains("2nd lunch") && minutes > 780) tardy = true;
        } else if (weekday == "Monday" || weekday == "Tuesday") {
            if (selectedLunch!.contains("1st lunch") && minutes > 739) {
              tardy = true;
            } else if (selectedLunch!.contains("2nd lunch") && minutes > 807) tardy = true;
        } else { // Thursday, Friday
            if (selectedLunch!.contains("1st lunch") && minutes > 754) {
              tardy = true;
            } else if (selectedLunch!.contains("2nd lunch") && minutes > 820) tardy = true;
        }

        final documentData = {
          'student_id': studentId,
          'timestamp': formattedDateTime,
          'purpose': dropdownValue,
          'tardy': tardy,
          'approved': false, // Default for Off-Campus Check-In
        };

        await firestore
            .collection('student_check-in_datalogs')
            .add(documentData);
        _showDialog( // Removed autoDismissDuration
            "Off-Campus Check-In for $barcodeCap recorded. Tardy: $tardy",
            tardy ? Colors.orangeAccent : Colors.green);
      } catch (e) {
        if (e is FormatException) {
          _showDialog(
              "Invalid barcode format for Student ID: $barcodeCap", Colors.red); // Removed autoDismissDuration
        } else {
          _showDialog("Error recording Off-Campus Check-In: $e", Colors.red); // Removed autoDismissDuration
        }
      }
    } else { // Attendance Check-In, Attendance Check-Out
      userData = await _queryUserByEmail(
          "$barcodeCap@students.cnusd.k12.ca.us"); // Assumes barcode is student ID number
      setState(() {
        _scanBarcodeResult = barcodeCap;
      });
      // Potentially show a confirmation dialog based on userData or tardy status from _queryUserByEmail
      if (userData != null && userData!.isNotEmpty) {
        bool isTardy = (await _queryUserByEmail("$barcodeCap@students.cnusd.k12.ca.us"))['tardy'] ?? false;
         _showDialog( // Removed autoDismissDuration
            "$dropdownValue for ${userData!['name']} ($barcodeCap) recorded. Tardy: $isTardy",
            isTardy ? Colors.orangeAccent : Colors.green);
      } else if (userData != null) { // userData is empty map
         _showDialog( // Removed autoDismissDuration
            "Student ID $barcodeCap not found. $dropdownValue recorded.",
            Colors.orangeAccent);
      }
    }

    if (_isPhysicalScannerModeActive && mounted) {
      // Clear the result after a short delay so the next scan is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _scanBarcodeResult = null;
            userData = null;
          });
          // Focus is now handled by _showDialog after dismissal.
          // FocusScope.of(context).requestFocus(_keyboardFocusNode); // REMOVE THIS LINE
        }
      });
    }
  }


  void _handleWebScanResultFromJs(String barcode) {
    logger.i("Web scan result from JS: $barcode");
    if (!mounted) return;
    setState(() {
      _isWebScannerVisible = false;
      _scanBarcodeResult = barcode;
    });
    _foundBarcode(barcode);

    // Automatically restart web scanner after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isPhysicalScannerModeActive) {
        setState(() {
          _isWebScannerVisible = true;
          _scanBarcodeResult = "Initializing web scanner...";
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted || !_isWebScannerVisible) return;
          try {
            platform_interop.callMethod(platform_interop.globalThis, 'initWebScanner', [
              _webVideoElement,
              '_flutterWebScanResultCallback',
              '_flutterWebScanErrorCallback'
            ]);
          } catch (e) {
            logger.e("Error calling initWebScanner from Dart: $e");
            _handleWebScanErrorFromJs("Failed to start web scanner: ${e.toString()}");
          }
        });
      }
    });
  }

  void _handleWebScanErrorFromJs(String errorMessage) {
    logger.e("Web scan error from JS: $errorMessage");
    if (!mounted) return;
    setState(() {
      _isWebScannerVisible = false;
    });
    _showDialog("Web scanning error: $errorMessage. Please try again or enter ID manually.", Colors.red);
  }

  Future<void> startBarcodeScanStream() async {
    if (_isPhysicalScannerModeActive) {
      _showDialog("Physical scanner mode is active. Use your handheld scanner.", Colors.blue);
      FocusScope.of(context).requestFocus(_keyboardFocusNode);
      return;
    }

    if (kIsWeb) {
      if (_isWebScannerVisible) {
        logger.i("User tapped to stop web scanner.");
        platform_interop.callMethod(platform_interop.globalThis, 'stopWebScanner', []); // Use the facade
        if (mounted) {
          setState(() {
            _isWebScannerVisible = false;
          });
        }
      } else {
        logger.i("User tapped to start web scanner.");
        if (mounted) {
          setState(() {
            _isWebScannerVisible = true;
            _scanBarcodeResult = "Initializing web scanner...";
          });
        }
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted || !_isWebScannerVisible) {
            if (_isWebScannerVisible) { // Check again in case it was stopped quickly
                platform_interop.callMethod(platform_interop.globalThis, 'stopWebScanner', []); // Use the facade
            }
            if (mounted && _isWebScannerVisible) setState(() => _isWebScannerVisible = false); // Ensure UI consistency
            return;
          }
          try {
            logger.d("Calling JS initWebScanner with video element: $_webVideoElement");
            platform_interop.callMethod(platform_interop.globalThis, 'initWebScanner', [ // Use the facade
              _webVideoElement,
              '_flutterWebScanResultCallback',
              '_flutterWebScanErrorCallback'
            ]);
          } catch (e) {
            logger.e("Error calling initWebScanner from Dart: $e");
            _handleWebScanErrorFromJs("Failed to start web scanner: ${e.toString()}");
          }
        });
      }
      return;
    }

    // --- Existing Mobile Scanning Logic ---
    String? barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      if (barcodeScanRes != '-1') {
        _foundBarcode(barcodeScanRes);

        // Automatically start next scan after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isPhysicalScannerModeActive) {
            startBarcodeScanStream();
          }
        });
      } else if (barcodeScanRes == '-1') {
        logger.i("Mobile barcode scan cancelled by user.");
        barcodeScanRes = "Scan cancelled.";
      }
    } on PlatformException catch (e) {
      logger.e("Mobile barcode scan PlatformException: ${e.message}");
      barcodeScanRes = 'Failed to get platform version.';
      _showDialog("Scanner Error: ${e.message}", Colors.red);
    } catch (e) {
      logger.e("Mobile barcode scan general error: $e");
      barcodeScanRes = "An unexpected error occurred during scan.";
      _showDialog(barcodeScanRes, Colors.red);
    }

    if (!mounted) return;
    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener( // Wrap with RawKeyboardListener
      focusNode: _keyboardFocusNode,
      onKey: _handleKeyPress,
      autofocus: _isPhysicalScannerModeActive, // Autofocus if physical scanner mode is initially true
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
            // ... (Your existing AppBar and header Stack remain the same) ...
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromRGBO(38, 99, 202, 1),
                Color.fromRGBO(20, 40, 75, 1)
              ])),
              child: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                automaticallyImplyLeading: false,
                toolbarHeight: 45,
                title: const Column(
                  children: [
                    Text(
                      "ERHS Mustangs",
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                    )
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color.fromRGBO(38, 99, 202, 1),
                    Color.fromRGBO(20, 40, 75, 1)
                  ])),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [
                        Color.fromRGBO(200, 140, 20, 1),
                        Color.fromRGBO(173, 58, 37, 1)
                      ])),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Transform.translate(
                    offset: const Offset(0, 45),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding( // Added padding around DropdownMenu
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                            child: DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.8, // Give it some width
                              initialSelection: items.first,
                              onSelected: (String? value) {
                                setState(() {
                                  dropdownValue = value!;
                                  isOffCampusSelected =
                                      value == 'Off-Campus Check-In' ||
                                          value == 'Off-Campus Check-Out';
                                  if (!isOffCampusSelected) {
                                    selectedLunch = null; // Reset lunch if not off-campus
                                  }
                                });
                              },
                              dropdownMenuEntries: items
                                  .map<DropdownMenuEntry<String>>((String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                          if (isOffCampusSelected)
                            Padding( // Added padding around DropdownButton
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                              child: DropdownButtonFormField<String>( // Used DropdownButtonFormField for better alignment and potential validation
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                ),
                                value: selectedLunch,
                                hint: Text('Select lunch period'),
                                items: <String>['1st lunch', '2nd lunch']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (_isPhysicalScannerModeActive && mounted) {
                                    FocusScope.of(context).requestFocus(_keyboardFocusNode);
                                  }
                                  setState(() {
                                    selectedLunch = newValue;
                                  });
                                },
                              ),
                            ),
                          // ADD THE TOGGLE BUTTON HERE
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton.icon(
                              icon: Icon(_isPhysicalScannerModeActive ? Icons.camera_alt : Icons.barcode_reader),
                              label: Text(_isPhysicalScannerModeActive ? 'Switch to Camera Scanner' : 'Switch to Physical Scanner'),
                              onPressed: _toggleScannerMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPhysicalScannerModeActive ? Colors.orangeAccent : Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.topCenter,
                            fit: StackFit.loose,
                            children: [
                              AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, _) {
                                    return Container(
                                        width: MediaQuery.of(context).size.width / 1.1,
                                        height: 300,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.5),
                                            gradient: LinearGradient(
                                                colors: const [
                                                  Color(0xffF99E43),
                                                  Color(0xFFDA2323),
                                                ],
                                                begin:
                                                    _topAlignmentAnimation.value,
                                                end: _bottomAlignmentAnimation
                                                    .value)),
                                        child: Center(
                                          child: Opacity(
                                            opacity: 0.25,
                                            child: AnimatedBuilder(
                                              animation: _animationController,
                                              builder: (BuildContext context, _) {
                                                return Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.1,
                                                  height: 300, // Match parent height
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.5),
                                                      gradient: LinearGradient(
                                                          colors: const [
                                                            Color.fromARGB(
                                                                255, 0, 42, 255),
                                                            Color.fromARGB(
                                                                255, 191, 0, 255),
                                                          ],
                                                          begin:
                                                              _topLeftAlignmentAnimation1
                                                                  .value,
                                                          end:
                                                              _bottomRightAlignmentAnimation1 // CHANGED HERE
                                                                  .value)),
                                                );
                                              },
                                            ),
                                          ),
                                        ));
                                  }),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_isPhysicalScannerModeActive) {
                                      FocusScope.of(context).requestFocus(_keyboardFocusNode);
                                      _showDialog("Physical scanner is active. Use your device to scan.", Colors.lightBlue);
                                    } else {
                                      startBarcodeScanStream();
                                    }
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width / 1.1,
                                    height: 300,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_isPhysicalScannerModeActive)
                                          Center(
                                            child: Text(
                                              "Physical Scanner Active\nPoint scanner and scan",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else if (kIsWeb && _isWebScannerVisible)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12.5),
                                            child: HtmlElementView(viewType: _webScannerViewType),
                                          )
                                        else if (kIsWeb && _isWebScannerVisible) // This was duplicated, keep the one above
                                          Container( // Guide box
                                            width: MediaQuery.of(context).size.width / 1.2, // Made wider
                                            height: 150, // Made taller
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.7),
                                                width: 2.0,
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Align barcode here",
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                        // else if (!(kIsWeb && _isWebScannerVisible)) // This condition is now part of the outer else
                                        else // Covers camera mode when web scanner is not yet visible or not web
                                          Center(
                                            child: Text(
                                              _isWebScannerVisible ? "Loading Camera..." : "Tap to Start Camera Scan",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding( // Added padding to the Row
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                              children: [
                                Container( // Student Picture
                                  height: 200, // Adjusted height
                                  width: 150,  // Adjusted width
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12), // Adjusted radius
                                      color: Colors.grey[300]),
                                  child: const Center(
                                    child: Text("Student\n Picture",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 18)), // Adjusted font
                                  ),
                                ),
                                const SizedBox(width: 16), // Spacing
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Name:", // Added colon for clarity
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Adjusted style
                                      ),
                                      Text(
                                        userData?['name'] ?? "---", // Placeholder
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "ID:",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _scanBarcodeResult ?? "---",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Grade:",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        userData?['grade']?.toString() ?? "---",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Year:",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        userData?['year']?.toString() ?? "---",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
                // ... (The rest of your Stack children for the header/title bar) ...
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.transparent,
                                child: const Text(
                                  textAlign: TextAlign.center,
                                  "Scan ID",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color.fromARGB(
                                          243, 248, 248, 248)),
                                ),
                              ),
                            )
                          ],
                        ),
                        // IconButton for back navigation
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }
                ),
              ],
            ),
          ]),
        ),
      ),
    ));
  }
}
