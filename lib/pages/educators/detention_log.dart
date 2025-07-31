import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// For debugPrint

class DetentionLog extends StatefulWidget {
  const DetentionLog({super.key});

  @override
  DetentionLogState createState() => DetentionLogState();
}

// Made class public to avoid private type in public API error
class DetentionLogState extends State<DetentionLog> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  bool isIdFilterActive = false; // New variable to track ID filter activation
  List<String> selectedItems = [];

  Future<List<Map<String, dynamic>>> getStudentCheckInData(
      String? idFilter, String? timeFilter, String? purposeFilter) async {
    final firestore = FirebaseFirestore.instance;
    var studentCheckInData = <Map<String, dynamic>>[];

    if (!selectedItems.contains("Student ID")) idFilter = "";
    if (!selectedItems.contains("Timestamp")) timeFilter = "";
    if (!selectedItems.contains("Purpose")) purposeFilter = "";

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

      // Ensure idFilter is applied correctly
      if (idFilter != null &&
          idFilter.isNotEmpty &&
          selectedItems.contains("Student ID")) {
        studentCheckInData = studentCheckInData
            .where((row) => row['Student ID'] != null &&
                row['Student ID'].toString().toLowerCase().contains(idFilter!.toLowerCase()))
            .toList();
      }

      List<Map<String, dynamic>> tardyData = [];

      for (var map in studentCheckInData) {
        if (tardyData.any((user) => user['Student ID'] == map['Student ID'])) {
          var toUpdate = tardyData
              .firstWhere((user) => user['Student ID'] == map['Student ID']);
          toUpdate['Tardies'] = toUpdate['Tardies'] + 1;
          toUpdate['Detentions'] = (toUpdate['Tardies'] + 1) ~/ 5;
        } else {
          tardyData.add({
            'Student ID': map['Student ID'],
            'Tardies': 1,
            'Detentions': 0,
          });
        }
      }

      return tardyData;
    } catch (e) {
      debugPrint('Error querying documents: $e');
      throw Exception('An error occurred while querying documents.');
    }
  }

  DataTable formatAsTable(List<Map<String, dynamic>> data) {
    final headers = data[0].keys.toList();

    final columns =
        headers.map((header) => DataColumn(label: Text(header))).toList();

    final rows = data.map((row) {
      return DataRow(
        cells: headers.map((header) {
          return DataCell(Text(row[header]?.toString() ?? ''));
        }).toList(),
      );
    }).toList();

    return DataTable(columns: columns, rows: rows);
  }

  @override
  Widget build(BuildContext context) {
    final barcode = isIdFilterActive ? _barcodeController.text : null; // Use filter only if active
    final time = _timeController.text;
    final purpose = _purposeController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detention Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Activate Student ID Filter'),
                      content: const Text('Do you want to activate the Student ID filter?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Activate'),
                        ),
                      ],
                    );
                  },
                );

                if (result == true) {
                  setState(() {
                    isIdFilterActive = true;
                  });
                }
              },
              child: const Text('Activate Student ID Filter'),
            ),
            if (isIdFilterActive) ...[
              TextField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Student ID',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {}); // Trigger rebuild to apply the filter
                },
                child: const Text('Apply Student ID Filter'),
              ),
            ],
            if (selectedItems.contains("Timestamp"))
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Time Range',
                ),
              ),
            if (selectedItems.contains("Purpose"))
              TextField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Purpose',
                ),
              ),
            const SizedBox(height: 20),
            if (selectedItems.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Apply Filters'),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: getStudentCheckInData(barcode, time, purpose),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      } else {
                        // Filter the displayed data to only include the entered ID
                        final filteredData = snapshot.data!
                            .where((row) => row['Student ID']
                                .toString()
                                .toLowerCase()
                                .contains(barcode?.toLowerCase() ?? ''))
                            .toList();
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: formatAsTable(filteredData),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
