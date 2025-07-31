import 'tutors_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tutors extends StatefulWidget {
  const Tutors({super.key});

  @override
  State<Tutors> createState() => _TutorsState();
}

class _TutorsState extends State<Tutors> {
  var db = FirebaseFirestore.instance;

  // Add state for search and filter
  String _searchText = '';
  String _selectedSubject = 'All';

  // List of subjects for dropdown
  final List<String> _subjects = [
    'All',
    'Math',
    'Computer Science',
    'English',
    'History',
    'Chemistry',
    'Physics',
    'Environmental Science',
    'World Language',
    'Music',
    'Art',
    'P.E. (Physical Education)'
  ];

  // Build the search and filter UI
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Subject filter dropdown
          DropdownButton<String>(
            value: _selectedSubject,
            items: _subjects
                .map((subject) => DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubject = value!;
              });
            },
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('tutor').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // Filter tutors based on search and subject
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final subject = (data['subject'] ?? '').toString().toLowerCase();

          final matchesName = name.contains(_searchText.toLowerCase());
          final matchesSubject = _selectedSubject == 'All' ||
              subject
                  .split(',')
                  .map((s) => s.trim().toLowerCase())
                  .contains(_selectedSubject.toLowerCase());

          return matchesName && matchesSubject;
        }).toList();

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return _buildCard(filteredDocs[index]);
          },
        );
      },
    );
  }

  Widget _buildCard(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    // Fetch tutorEmail and tutorUserID from the Firestore document data
    // Ensure your Firestore 'tutor' documents have 'Email' and 'UserID' fields.
    // If the field names are different (e.g., 'email', 'userId'), adjust them here.
    final String? tutorEmail = data['mail'] as String?;
    final String? tutorUserID = data['uid'] as String?;

    // Use imgPath or image field, prioritize imgPath
    String? rawImagePath =
        data['imgPath'] as String? ?? data['image'] as String? ?? '';
    String imagePath = rawImagePath.trim();

    // Remove leading 'assets/' if exists because Flutter adds it automatically
    if (imagePath.startsWith('assets/')) {
      imagePath = imagePath.substring(7);
    }

    final String name = data['name'] as String? ?? 'N/A';
    final String description =
        data['description'] as String? ?? 'No description';
    final String subject = data['subject'] as String? ?? 'N/A';

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TutorsInfo(
                      tutorName: name,
                      tutorDesc: description,
                      tutorImg: imagePath,
                      tutorSubject: subject,
                      tutorEmail: tutorEmail,
                      tutorUserID: tutorUserID,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
              color: Colors.grey.shade300, // Lighter grey
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        height: 150, // Adjust as needed
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: FractionalOffset.center,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Text(
                            'Image failed to load',
                            textAlign: TextAlign.center,
                          ));
                        },
                      )
                    : const Center(
                        child: Text(
                          'No image available',
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: 'Subjects: ',
                          style: const TextStyle(fontSize: 11),
                          children: [
                            TextSpan(
                              text: subject,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle:
                                    subject.trim() == 'Subject not Specified'
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform.translate(
                    offset: const Offset(0, 45),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 1.15,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20)),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Add search and filter UI here
                            _buildSearchAndFilter(),
                            SizedBox(child: _buildUserList()),
                            const SizedBox(height: 100),
                            Column(
                              children: [],
                            )
                          ],
                        ),
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
                                "Tutors",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(243, 248, 248, 248)),
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
                  }),
            ],
          ),
        ]),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(-size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
