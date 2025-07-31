import 'package:english_words/english_words.dart';
import 'components/educator_my_drawer.dart';
import 'detention_log.dart';
import 'educator_student_log_queries.dart';
import 'scan_id.dart';
import '../../themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(const MyApp());

String getWeekday() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE');
  final String weekday = formatter.format(now);
  return weekday;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'ERHS App',
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: EducatorAgenda(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class EducatorAgenda extends StatefulWidget {
  const EducatorAgenda({super.key});

  @override
  _EducatorAgendaState createState() => _EducatorAgendaState();
}

class _EducatorAgendaState extends State<EducatorAgenda> with SingleTickerProviderStateMixin{
  Timer? _timer;
  String _selectedLunchType = "A"; // Default lunch type
  String _selectedScheduleMode = "Weekday"; // "Weekday", "White Rally", "Orange Rally", "Blue Rally"

  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      // Updates UI every 5 seconds
      setState(() {});
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

    _animationController.repeat();
  }

  @override
  void dispose() {
    // Cancels timer when widget not used
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String weekday = getWeekday().toLowerCase();
    final DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String period = ""; // Initialize period
    int minutes = hour * 60 + minute;
    int upperBound = 0; // Initialize upperBound

    int schoolStartTime = 0;
    int schoolEndTime = 0;

    if (_selectedScheduleMode == "White Rally") {
      schoolStartTime = 510; // 8:30 AM
      schoolEndTime = 936; // 3:36 PM

      if (minutes < schoolStartTime) {
        period = "Out of School";
        upperBound = schoolStartTime;
      } else if (minutes >= 510 && minutes < 515) {
        // Passing to White Assembly/Activity: 8:30 - 8:35
        period = "Passing to White Assembly";
        upperBound = 515;
      } else if (minutes >= 515 && minutes < 560) {
        // White Assembly/Activity: 8:35 - 9:20
        period = "White Assembly/Activity";
        upperBound = 560;
      } else if (minutes >= 560 && minutes < 565) {
        // White Assembly/passing back to 1/2: 9:20 - 9:25
        period = "White Assembly/Passing to 1/2";
        upperBound = 565;
      } else if (minutes >= 565 && minutes < 670) {
        // Remaining Period 1/2 for White: 9:25 - 11:10
        period = "Remaining Period 1/2 (White)";
        upperBound = 670;
      }
      // Common Rally Periods from 11:10 AM (670 minutes)
      else if (minutes >= 670 && minutes < 678) {
        // Passing to Per 3/4 for all: 11:10 - 11:18
        period = "Passing to Period 3/4";
        upperBound = 678;
      } else if (minutes >= 678 && minutes < 823) {
        // Period 3/4 & Lunch Block: 11:18 AM - 1:43 PM
        if (_selectedLunchType == "A") {
          if (minutes >= 678 && minutes < 735) {
            period = "Period 3/4 A (Pre-Lunch)";
            upperBound = 735;
          } // 11:18 - 12:15
          else if (minutes >= 735 && minutes < 775) {
            period = "LUNCH A";
            upperBound = 775;
          } // 12:15 - 12:55
          else if (minutes >= 775 && minutes < 783) {
            period = "Passing to Period 3/4A";
            upperBound = 783;
          } // 12:55 - 1:03
          else if (minutes >= 783 && minutes < 823) {
            period = "Period 3/4A (Post-Lunch)";
            upperBound = 823;
          } // 1:03 - 1:43
        } else {
          // Lunch B
          if (minutes >= 678 && minutes < 783) {
            period = "Period 3/4B (Pre-Lunch)";
            upperBound = 783;
          } // 11:18 - 1:03
          else if (minutes >= 783 && minutes < 823) {
            period = "LUNCH B";
            upperBound = 823;
          } // 1:03 - 1:43
        }
      } else if (minutes >= 823 && minutes < 831) {
        // Passing to Per 5/6 all: 1:43 PM - 1:51 PM
        period = "Passing to Period 5/6";
        upperBound = 831;
      } else if (minutes >= 831 && minutes <= 936) {
        // Period 5/6: 1:51 PM - 3:36 PM
        period = "Period 5/6";
        upperBound = 936;
      }
      // End of day / Fallback
      else if (minutes > schoolEndTime) {
        period = "Out of School";
        upperBound = schoolEndTime;
      } else {
        // Fallback if within school hours but no specific period matched
        period = "Passing Period";
        upperBound = minutes;
      }
    } else if (_selectedScheduleMode == "Orange Rally") {
      schoolStartTime = 510; // 8:30 AM
      schoolEndTime = 936; // 3:36 PM

      if (minutes < schoolStartTime) {
        period = "Out of School";
        upperBound = schoolStartTime;
      } else if (minutes >= 510 && minutes < 565) {
        // Period 1/2: 8:30 - 9:25
        period = "Period 1/2";
        upperBound = 565;
      } else if (minutes >= 565 && minutes < 570) {
        // Passing to Orange Assembly/Activity: 9:25 - 9:30
        period = "Passing to Orange Assembly";
        upperBound = 570;
      } else if (minutes >= 570 && minutes < 615) {
        // Orange Assembly/Activity: 9:30 - 10:15
        period = "Orange Assembly/Activity";
        upperBound = 615;
      } else if (minutes >= 615 && minutes < 620) {
        // Orange Assembly passing back to 1/2: 10:15 - 10:20
        period = "Orange Assembly/Passing to 1/2";
        upperBound = 620;
      } else if (minutes >= 620 && minutes < 670) {
        // Remaining Period 1 for Orange: 10:20 - 11:10
        period = "Remaining Period 1 (Orange)";
        upperBound = 670;
      }
      // Common Rally Periods from 11:10 AM (670 minutes)
      else if (minutes >= 670 && minutes < 678) {
        // Passing to Per 3/4 for all: 11:10 - 11:18
        period = "Passing to Period 3/4";
        upperBound = 678;
      } else if (minutes >= 678 && minutes < 823) {
        // Period 3/4 & Lunch Block: 11:18 AM - 1:43 PM
        if (_selectedLunchType == "A") {
          if (minutes >= 678 && minutes < 735) {
            period = "Period 3/4A (Pre-Lunch)";
            upperBound = 735;
          } else if (minutes >= 735 && minutes < 775) {
            period = "Lunch A";
            upperBound = 775;
          } else if (minutes >= 775 && minutes < 783) {
            period = "Passing to Period 3/4A";
            upperBound = 783;
          } else if (minutes >= 783 && minutes < 823) {
            period = "Period 3/4 A (Post-Lunch)";
            upperBound = 823;
          }
        } else {
          // Lunch B
          if (minutes >= 678 && minutes < 783) {
            period = "Period 3/4 B";
            upperBound = 783;
          } else if (minutes >= 783 && minutes < 823) {
            period = "Lunch B";
            upperBound = 823;
          }
        }
      } else if (minutes >= 823 && minutes < 831) {
        // Passing to Per 5/6 all: 1:43 PM - 1:51 PM
        period = "Passing to Period 5/6";
        upperBound = 831;
      } else if (minutes >= 831 && minutes <= 936) {
        // Period 5/6: 1:51 PM - 3:36 PM
        period = "Period 5/6";
        upperBound = 936;
      }
      // End of day / Fallback
      else if (minutes > schoolEndTime) {
        period = "Out of School";
        upperBound = schoolEndTime;
      } else {
        period = "Passing Period";
        upperBound = minutes;
      }
    } else if (_selectedScheduleMode == "Blue Rally") {
      schoolStartTime = 510; // 8:30 AM
      schoolEndTime = 936; // 3:36 PM

      if (minutes < schoolStartTime) {
        period = "Out of School";
        upperBound = schoolStartTime;
      } else if (minutes >= 510 && minutes < 620) {
        // Period 1/2: 8:30 - 10:20
        period = "Period 1/2";
        upperBound = 620;
      } else if (minutes >= 620 && minutes < 625) {
        // Passing to Blue Assembly/Activity: 10:20 - 10:25
        period = "Passing to Blue Assembly";
        upperBound = 625;
      } else if (minutes >= 625 && minutes < 670) {
        // Blue Assembly/Activity: 10:25 - 11:10
        period = "Blue Assembly/Activity";
        upperBound = 670;
      }
      // Common Rally Periods from 11:10 AM (670 minutes)
      else if (minutes >= 670 && minutes < 678) {
        // Passing to Per 3/4 for all: 11:10 - 11:18
        period = "Passing to Period 3/4";
        upperBound = 678;
      } else if (minutes >= 678 && minutes < 823) {
        // Period 3/4 & Lunch Block: 11:18 AM - 1:43 PM
        if (_selectedLunchType == "A") {
          if (minutes >= 678 && minutes < 735) {
            period = "Period 3/4A (Pre-Lunch)";
            upperBound = 735;
          } else if (minutes >= 735 && minutes < 775) {
            period = "LUNCH A";
            upperBound = 775;
          } else if (minutes >= 775 && minutes < 783) {
            period = "Passing to Period 3/4A";
            upperBound = 783;
          } else if (minutes >= 783 && minutes < 823) {
            period = "Period 3/4A (Post-Lunch)";
            upperBound = 823;
          }
        } else {
          // Lunch B
          if (minutes >= 678 && minutes < 783) {
            period = "Period 3/4B (Pre-Lunch)";
            upperBound = 783;
          } else if (minutes >= 783 && minutes < 823) {
            period = "LUNCH B";
            upperBound = 823;
          }
        }
      } else if (minutes >= 823 && minutes < 831) {
        // Passing to Per 5/6 all: 1:43 PM - 1:51 PM
        period = "Passing to Period 5/6";
        upperBound = 831;
      } else if (minutes >= 831 && minutes <= 936) {
        // Period 5/6: 1:51 PM - 3:36 PM
        period = "Period 5/6";
        upperBound = 936;
      }
      // End of day / Fallback
      else if (minutes > schoolEndTime) {
        period = "Out of School";
        upperBound = schoolEndTime;
      } else {
        period = "Passing";
        upperBound = minutes;
      }
    } else {
      // "Weekday" mode - existing weekday logic
      switch (weekday.toLowerCase()) {
        case "monday":
        case "tuesday":
          schoolStartTime = 440; // 7:20 AM
          schoolEndTime = 936; // 3:36 PM

          if (minutes < schoolStartTime) {
            period = "Out of School";
            upperBound = schoolStartTime; // Time until school starts
          } else if (minutes >= 440 && minutes <= 502) {
            // Zero: 7:20-8:22
            period = "Period 0";
            upperBound = 502;
          } else if (minutes >= 503 && minutes <= 509) {
            // Passing: 8:23-8:29
            period = "Passing Period";
            upperBound = 509;
          } else if (minutes >= 510 && minutes <= 631) {
            // 1/2: 8:30-10:31
            period = "Period 1/2";
            upperBound = 631;
          } else if (minutes >= 632 && minutes <= 638) {
            // Passing: 10:32-10:38
            period = "Passing Period";
            upperBound = 638;
          }
          // Lunch specific logic
          else if (_selectedLunchType == "A") {
            if (minutes >= 639 && minutes <= 698) {
              // 3/4 A (Part 1): 10:39-11:38 (Image: 3/4 is 10:39-11:39, LUNCH A is 11:39-12:19. So 3/4A ends 11:38)
              period = "Period 3/4A";
              upperBound = 698;
            } else if (minutes >= 699 && minutes <= 739) {
              // LUNCH A: 11:39-12:19
              period = "LUNCH A";
              upperBound = 739;
            } else if (minutes >= 740 && minutes <= 746) {
              // Passing: 12:20-12:26
              period = "Passing Period";
              upperBound = 746;
            } else if (minutes >= 747 && minutes <= 807) {
              // 3/4 A (Post-Lunch): 12:27-1:27
              period = "Period 3/4A (Post-Lunch)";
              upperBound = 807;
            } else if (minutes >= 808 && minutes <= 814) {
              // Passing: 1:28-1:34
              period = "Passing Period";
              upperBound = 814;
            } else if (minutes >= 815 && minutes <= 936) {
              // 5/6: 1:35-3:36
              period = "Period 5/6";
              upperBound = 936;
            }
          } else if (_selectedLunchType == "B") {
            if (minutes >= 639 && minutes <= 766) {
              // 3/4 B: 10:39-12:46 (Image: 3/4 B is 10:39-12:47, LUNCH B is 12:47-1:27. So 3/4B ends 12:46)
              period = "Period 3/4B (Pre-Lunch)";
              upperBound = 766;
            } else if (minutes >= 767 && minutes <= 807) {
              // LUNCH B: 12:47-1:27
              period = "LUNCH B";
              upperBound = 807;
            } else if (minutes >= 808 && minutes <= 814) {
              // Passing: 1:28-1:34 (Same as after A lunch path)
              period = "Passing Period";
              upperBound = 814;
            } else if (minutes >= 815 && minutes <= 936) {
              // 5/6: 1:35-3:36 (Same as after A lunch path)
              period = "Period 5/6";
              upperBound = 936;
            }
          }

          if (period.isEmpty && minutes > schoolEndTime) {
            period = "Out of School";
            upperBound = schoolEndTime; // Or minutes if "time left" should be 0
          } else if (period.isEmpty &&
              minutes >= schoolStartTime &&
              minutes <= schoolEndTime) {
            period =
                "Passing Period"; // Fallback if within school hours but no specific period
            upperBound = minutes; // Time left will be 0
          }
          break;

        case "wednesday":
          schoolStartTime = 590; // 9:50 AM
          schoolEndTime = 936; // 3:36 PM

          if (minutes < schoolStartTime) {
            period = "Out of School";
            upperBound = schoolStartTime;
          } else if (minutes >= 590 && minutes <= 635) {
            // 1: 9:50-10:35
            period = "Period 1";
            upperBound = 635;
          } else if (minutes >= 636 && minutes <= 642) {
            // Passing: 10:36-10:42
            period = "Passing Period";
            upperBound = 642;
          } else if (minutes >= 643 && minutes <= 687) {
            // 2: 10:43-11:27 (Image: 2 is 10:43-11:28, LUNCH A is 11:28-12:08. So P2 ends 11:27)
            period = "Period 2";
            upperBound = 687;
          }
          // Lunch specific logic for Wednesday
          else if (_selectedLunchType == "A") {
            if (minutes >= 688 && minutes <= 728) {
              // LUNCH A: 11:28-12:08
              period = "LUNCH A";
              upperBound = 728;
            } else if (minutes >= 729 && minutes <= 735) {
              // Passing: 12:09-12:15
              period = "Passing Period";
              upperBound = 735;
            } else if (minutes >= 736 && minutes <= 780) {
              // 3 A: 12:16-1:00
              period = "Period 3A";
              upperBound = 780;
            }
          } else if (_selectedLunchType == "B") {
            // For Lunch B on Wednesday, P2 ends 11:27. 3B starts 11:36. So passing is 11:28-11:35
            if (minutes >= 688 && minutes <= 695) {
              // Passing (after P2, before 3B): 11:28-11:35
              period = "Passing Period";
              upperBound = 695;
            } else if (minutes >= 696 && minutes <= 739) {
              // 3 B: 11:36-12:19 (Image: 3B is 11:36-12:20, LUNCH B is 12:20-1:00. So 3B ends 12:19)
              period = "Period 3B";
              upperBound = 739;
            } else if (minutes >= 740 && minutes <= 780) {
              // LUNCH B: 12:20-1:00
              period = "LUNCH B";
              upperBound = 780;
            }
          }
          // Common periods after lunch paths for Wednesday (after 1:00 PM / 780 minutes)
          if (period.isEmpty && minutes > 780 && minutes <= schoolEndTime) {
            if (minutes >= 781 && minutes <= 787) {
              // Passing: 1:01-1:07
              period = "Passing Period";
              upperBound = 787;
            } else if (minutes >= 788 && minutes <= 832) {
              // 4: 1:08-1:52
              period = "Period 4";
              upperBound = 832;
            } else if (minutes >= 833 && minutes <= 839) {
              // Passing: 1:53-1:59
              period = "Passing Period";
              upperBound = 839;
            } else if (minutes >= 840 && minutes <= 884) {
              // 5: 2:00-2:44
              period = "Period 5";
              upperBound = 884;
            } else if (minutes >= 885 && minutes <= 891) {
              // Passing: 2:45-2:51
              period = "Passing Period";
              upperBound = 891;
            } else if (minutes >= 892 && minutes <= 936) {
              // 6: 2:52-3:36
              period = "Period 6";
              upperBound = 936;
            }
          }

          if (period.isEmpty && minutes > schoolEndTime) {
            period = "Out of School";
            upperBound = schoolEndTime;
          } else if (period.isEmpty &&
              minutes >= schoolStartTime &&
              minutes <= schoolEndTime) {
            period = "Passing Period";
            upperBound = minutes;
          }
          break;

        case "thursday":
        case "friday":
          schoolStartTime = 440; // 7:20 AM
          schoolEndTime = 936; // 3:36 PM

          if (minutes < schoolStartTime) {
            period = "Out of School";
            upperBound = schoolStartTime;
          } else if (minutes >= 440 && minutes <= 502) {
            // Zero: 7:20-8:22
            period = "Period 0";
            upperBound = 502;
          } else if (minutes >= 503 && minutes <= 509) {
            // Passing: 8:23-8:29
            period = "Passing";
            upperBound = 509;
          } else if (minutes >= 510 && minutes <= 618) {
            // 1/2: 8:30-10:18
            period = "Period 1/2";
            upperBound = 618;
          } else if (minutes >= 619 && minutes <= 625) {
            // Passing: 10:19-10:25
            period = "Passing Period";
            upperBound = 625;
          } else if (minutes >= 626 && minutes <= 656) {
            // Office Hours: 10:26-10:56
            period = "Office Hours";
            upperBound = 656;
          } else if (minutes >= 657 && minutes <= 663) {
            // Passing: 10:57-11:03
            period = "Passing Period";
            upperBound = 663;
          }
          // Lunch specific logic for Thursday/Friday
          else if (_selectedLunchType == "A") {
            if (minutes >= 664 && minutes <= 713) {
              // 3/4 A (Part 1): 11:04-11:53 (Image: 3/4 is 11:04-11:54, LUNCH A is 11:54-12:34. So 3/4A ends 11:53)
              period = "Period 3/4A";
              upperBound = 713;
            } else if (minutes >= 714 && minutes <= 754) {
              // LUNCH A: 11:54-12:34
              period = "LUNCH A";
              upperBound = 754;
            } else if (minutes >= 755 && minutes <= 761) {
              // Passing: 12:35-12:41
              period = "Passing Period";
              upperBound = 761;
            } else if (minutes >= 762 && minutes <= 820) {
              // 3/4 A (Post-Lunch): 12:42-1:40
              period = "Period 3/4A (Post-Lunch)";
              upperBound = 820;
            }
          } else if (_selectedLunchType == "B") {
            if (minutes >= 664 && minutes <= 779) {
              // 3/4 B: 11:04-12:59 (Image: 3/4 B is 11:04-1:00, LUNCH B is 1:00-1:40. So 3/4B ends 12:59)
              period = "Period 3/4B (Pre-Lunch)";
              upperBound = 779;
            } else if (minutes >= 780 && minutes <= 820) {
              // LUNCH B: 1:00-1:40
              period = "LUNCH B";
              upperBound = 820;
            }
          }
          // Common periods after lunch paths for Thursday/Friday (after 1:40 PM / 820 minutes)
          if (period.isEmpty && minutes > 820 && minutes <= schoolEndTime) {
            if (minutes >= 821 && minutes <= 827) {
              // Passing: 1:41-1:47
              period = "Passing Period";
              upperBound = 827;
            } else if (minutes >= 828 && minutes <= 936) {
              // 5/6: 1:48-3:36
              period = "Period 5/6";
              upperBound = 936;
            }
          }

          if (period.isEmpty && minutes > schoolEndTime) {
            period = "Out of School";
            upperBound = schoolEndTime;
          } else if (period.isEmpty &&
              minutes >= schoolStartTime &&
              minutes <= schoolEndTime) {
            period = "Passing Period";
            upperBound = minutes;
          }
          break;
        default: // Weekend or unknown day
          period = "Out of School";
          upperBound = minutes; // Time left will be 0
          break;
      }

      // Final fallback if period is somehow still not set
      if (period.isEmpty) {
        if (minutes < schoolStartTime &&
            (weekday == "monday" ||
                weekday == "tuesday" ||
                weekday == "thursday" ||
                weekday == "friday" ||
                weekday == "wednesday")) {
          period = "Out of School";
          upperBound = schoolStartTime;
        } else if (minutes > schoolEndTime &&
            (weekday == "monday" ||
                weekday == "tuesday" ||
                weekday == "thursday" ||
                weekday == "friday" ||
                weekday == "wednesday")) {
          period = "Out of School";
          upperBound = schoolEndTime;
        } else if (weekday != "saturday" && weekday != "sunday") {
          // If it's a school day but unassigned
          period = "Passing";
          upperBound = minutes;
        } else {
          // Weekend
          period = "Out of School";
          upperBound = minutes;
        }
      }

      if (weekday == "saturday" || weekday == "sunday") {
        period = "Out of School"; // No school on weekends
        upperBound = minutes; // Time left will be 0
      }
    }

    void signUserOut() {
      FirebaseAuth.instance.signOut();
    }

    return Scaffold(
      drawer: EducatorMyDrawer(),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color.fromRGBO(38, 99, 202, 1), Color.fromRGBO(20, 40, 75, 1)])
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                automaticallyImplyLeading: false,
                toolbarHeight: 45,
                leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
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
                    gradient: LinearGradient(colors: [Color.fromRGBO(38, 99, 202, 1), Color.fromRGBO(20, 40, 75, 1)])
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(colors: [Color.fromRGBO(200, 140, 20, 1), Color.fromRGBO(173, 58, 37, 1)])
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 35.0, right: 10.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              signUserOut();
                            },
                            child: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 45),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/1.15 - 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      ),
                                      value: _selectedScheduleMode,
                                      hint: const Text('Select Schedule'),
                                      items: <String>[
                                        'Weekday',
                                        'White Rally',
                                        'Orange Rally',
                                        'Blue Rally'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value == "Weekday" ? "Weekday" : "$value Schedule"),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedScheduleMode = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      ),
                                      value: _selectedLunchType,
                                      hint: Text('Select lunch type'),
                                      items: <String>['A', 'B'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text('Lunch $value'),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedLunchType = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  const Text(
                                    '\nCurrently, it\'s ',
                                    style: TextStyle(
                                      fontSize: 20.0
                                    )
                                  ),
                                  Text(
                                    period == "Out of School" ? 'Out of School' : '$period\n\n',
                                    style: const TextStyle(
                                      fontSize: 18.5
                                    )
                                  ),
                                  period == "Out of School" ? SizedBox() : Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blueGrey[200],
                                        )
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Time left:',
                                            style: TextStyle(
                                              fontSize: 19, color: Colors.black
                                            )
                                          ),
                                          Text(
                                            "${upperBound - minutes} minutes",
                                            style: const TextStyle(
                                              fontSize: 19, color: Colors.black
                                            )
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  // Add links below the circle
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final Uri url = Uri.parse("https://acrobat.adobe.com/id/urn:aaid:sc:AP:8c379e72-8ae5-5b79-9997-c88228fe2a79"); // Replace with your actual URL
                                            if (!await launchUrl(url)) {
                                              // Handle error, e.g., show a snackbar
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Could not launch $url')),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "View Regular Bell Schedule PDF",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10), // Spacing between links
                                        InkWell(
                                          onTap: () async {
                                            final Uri url = Uri.parse("https://acrobat.adobe.com/id/urn:aaid:sc:AP:1f682758-e09d-444a-bd1b-7c8362165351"); // Replace with your actual URL for the Rally schedule
                                            if (!await launchUrl(url)) {
                                              // Handle error
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Could not launch $url')),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "View Rally Schedule PDF", // Changed text
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        // You might want to add a third link if the "Assembly Schedule" was different from "Rally Schedule"
                                        // For now, I've repurposed the second link for the Rally Schedule PDF.
                                        // If you have a separate Assembly schedule (non-rally), add another InkWell here.
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                                  "Welcome, Educator!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(243, 248, 248, 248)
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Material(
                    elevation: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.5),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const StudentCheckIn()));
                          },
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, _) {
                              return Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.5),
                                    gradient: LinearGradient(
                                        colors: const [
                                          Colors.blue,
                                          Colors.lightBlue
                                        ],
                                        begin: _topAlignmentAnimation.value,
                                        end: _bottomAlignmentAnimation.value)),
                                child: const Icon(
                                  Icons.table_rows_outlined,
                                  color: Colors.white,
                                ),
                              );
                            }
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const DetentionLog()));
                          },
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, _) {
                              return Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.5),
                                    gradient: LinearGradient(
                                        colors: const [
                                          Color(0xffF99E43),
                                          Color(0xFFDA2323),
                                        ],
                                        begin: _topAlignmentAnimation.value,
                                        end: _bottomAlignmentAnimation.value)),
                                child: const Icon(
                                  Icons.table_chart_rounded,
                                  color: Colors.white,
                                ),
                              );
                            }
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const ScanPage()));
                          },
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, _) {
                              return Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.5),
                                    gradient: LinearGradient(
                                        colors: const [
                                          Colors.deepPurple,
                                          Colors.purple,
                                        ],
                                        begin: _topAlignmentAnimation.value,
                                        end: _bottomAlignmentAnimation.value)),
                                child: const Icon(
                                  Icons.barcode_reader,
                                  color: Colors.white,
                                ),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
