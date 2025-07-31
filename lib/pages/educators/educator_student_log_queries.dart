import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart'; // Date picker
import 'package:animated_custom_dropdown/custom_dropdown.dart'; // Dropdown

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  const MultiSelect(
      {super.key, required this.items, required this.selectedItems});

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems.addAll(widget.selectedItems);
  }

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedItems.add(itemValue);
      } else {
        selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Topics'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class StudentCheckIn extends StatefulWidget {
  const StudentCheckIn({super.key});

  @override
  StudentCheckInState createState() => StudentCheckInState();
}

class StudentCheckInState extends State<StudentCheckIn> {
  final TextEditingController _barcodeController = TextEditingController();
  String? selectedPurpose; // Initialize as an empty string
  List<String> selectedItems = [];
  DateTime? startDate;
  DateTime? endDate;

  final List<String> purposeList = [
    'Attendance Check-In',
    'Attendance Check-Out',
    'Off-Campus Check-In',
    'Off-Campus Check-Out',
    'Event Check-In',
    'Event Check-Out',
  ]; // Purpose list

  @override
  void initState() {
    super.initState();
    selectedPurpose = purposeList[0]; // Initialize with default in initState
  }

  void _showMultiSelect() async {
    final List<String> items = ['Student ID', 'Timestamp', 'Purpose'];

    final List<String>? results = await showDialog(
      context: context,
      builder: (context) {
        return MultiSelect(items: items, selectedItems: selectedItems);
      },
    );

    if (results != null) {
      setState(() {
        selectedItems = results;
      });
    }
  }

  void _selectDateRange() {
    showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime(2000),
      maximumDate: DateTime(2100),
      endDate: endDate,
      startDate: startDate,
      backgroundColor: Colors.white,
      primaryColor: Colors.orange,
      onApplyClick: (start, end) {
        setState(() {
          startDate = start;
          endDate = end;
        });
      },
      onCancelClick: () {
        setState(() {
          startDate = null;
          endDate = null;
        });
      },
    );
  }

  Future<List<Map<String, dynamic>>> getStudentCheckInData(
      String? idFilter, String? purposeFilter) async {
    final firestore = FirebaseFirestore.instance;
    var studentCheckInData = <Map<String, dynamic>>[];

    try {
      final querySnapshot =
          await firestore.collection('student_check-in_datalogs').get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No documents found');
      }

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final studentId = data['student_id'];
        final timestamp = data['timestamp'];
        final purpose = data['purpose'];
        final tardy = data['tardy'];

        studentCheckInData.add({
          'Student ID': studentId,
          'Timestamp': timestamp,
          'Purpose': purpose,
          'Tardy': tardy,
        });
      }

      // Apply filters
      List<Map<String, dynamic>> filteredData = studentCheckInData;

      if (idFilter != null &&
          idFilter.isNotEmpty &&
          selectedItems.contains("Student ID")) {
        filteredData = filteredData
            .where((row) => row['Student ID'] != null &&
                           row['Student ID'].toString().toLowerCase() == idFilter.toLowerCase())
            .toList();
      }

      if (purposeFilter != null &&
          purposeFilter.isNotEmpty &&
          selectedItems.contains("Purpose")) {
        filteredData = filteredData
            .where((row) => row['Purpose'] != null &&
                           row['Purpose'].toString() == purposeFilter)
            .toList();
      }

      if (startDate != null &&
          endDate != null &&
          selectedItems.contains("Timestamp")) {
        filteredData = filteredData
            .where((row) {
              final timestamp = row['Timestamp'];
              if (timestamp == null) return false;

              final date = DateTime.tryParse(timestamp.toString());
              if (date == null) return false;

              return date.isAfter(startDate!) && date.isBefore(endDate!);
            })
            .toList();
      }

      if (filteredData.isEmpty) {
        throw Exception('No data found for the given filters.');
      }

      return filteredData;
    } catch (e) {
      throw Exception('An error occurred while querying documents. Please try again later.');
    }
  }

  DataTable formatAsTable(List<Map<String, dynamic>> data) {
    final headers = data[0].keys.toList();
    final columns =
        headers.map((header) => DataColumn(label: Text(header))).toList();
    final rows = data.map((row) {
      return DataRow(
        cells: headers
            .map((header) => DataCell(Text(row[header]?.toString() ?? '')))
            .toList(),
      );
    }).toList();

    return DataTable(columns: columns, rows: rows);
  }

  @override
  Widget build(BuildContext context) {
    var barcode = _barcodeController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tardy Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showMultiSelect,
              child: const Text('Show Filters'),
            ),
            const SizedBox(
                height: 20), // Space between the button and the dropdown
            if (selectedItems.contains("Student ID")) ...[
              TextField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Barcode',
                ),
              ),
              const SizedBox(height: 20), // Space between each field
            ],
            if (selectedItems.contains("Timestamp")) ...[
              ElevatedButton(
                onPressed: _selectDateRange,
                child: const Text('Select Date Range'),
              ),
              const SizedBox(height: 20), // Space between each field
            ],
            if (selectedItems.contains("Purpose")) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          Colors.grey), // Adding a border around the dropdown
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(8.0),
                child: CustomDropdown<String>(
                  hintText: 'Select Purpose',
                  items: purposeList,
                  initialItem: selectedPurpose,
                  onChanged: (value) {
                    setState(() {
                      selectedPurpose = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20), // Space between each field
            ],
            if (selectedItems.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  barcode = _barcodeController.text;
                  setState(() {});
                },
                child: const Text('Apply Filters'),
              ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getStudentCheckInData(barcode, selectedPurpose),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available'));
                    } else {
                      final data = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: formatAsTable(data),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
