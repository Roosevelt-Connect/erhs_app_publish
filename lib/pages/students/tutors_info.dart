import '../../models/customicons.dart';
import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class TutorsInfo extends StatefulWidget {
  final String tutorName;
  final String tutorDesc;
  final String tutorImg;
  final String tutorSubject;
  final String? tutorEmail;
  final String? tutorUserID;

  const TutorsInfo({
    super.key,
    required this.tutorName,
    required this.tutorDesc,
    required this.tutorImg,
    required this.tutorSubject,
    this.tutorEmail,
    this.tutorUserID,
  });

  @override
  State<TutorsInfo> createState() => _TutorsInfoState();
}

class _TutorsInfoState extends State<TutorsInfo> {
  var db = FirebaseFirestore.instance;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromRGBO(38, 99, 202, 1),
                Color.fromRGBO(20, 40, 75, 1)
              ]),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 45,
              title: const Text(
                "ERHS Mustangs",
                style: TextStyle(color: Colors.white, fontSize: 25.0),
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
                  ]),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [
                    Color.fromRGBO(200, 140, 20, 1),
                    Color.fromRGBO(173, 58, 37, 1)
                  ]),
                ),
                child: Transform.translate(
                  offset: const Offset(0, -17.5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_outlined,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.tutorName,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 48), // Match width of IconButton (approx.)
                    ],
                  ),
                ),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: widget.tutorImg.isNotEmpty
                                  ? Image.asset(
                                      widget.tutorImg,
                                      height: 200,
                                      width: 300,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          width: 300,
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child:
                                                  Text('Image not available')),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 200,
                                      width: 300,
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: Text('No image provided')),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            const Text("Description",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.tutorDesc,
                                  textAlign: TextAlign.center),
                            ),
                            const Text("Subjects",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.tutorSubject,
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 16.0),
                              child: (widget.tutorEmail != null &&
                                      widget.tutorUserID != null)
                                  ? ElevatedButton.icon(
                                      icon: const Icon(Icons.message_outlined),
                                      label: const Text('Message Tutor'),
                                      onPressed: () {
                                        print(
                                            'Tutor Name: ${widget.tutorName}');
                                        print(
                                            'Tutor Email: ${widget.tutorEmail}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              receiverUserName: widget
                                                  .tutorName, // <<<<<<<<<<<<<< ADDED THIS LINE
                                              receiverUserEmail:
                                                  widget.tutorEmail!,
                                              receiverUserID:
                                                  widget.tutorUserID!,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        textStyle:
                                            const TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : const Text(
                                      'Messaging not available for this tutor.'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const GradientIcon(
                                    icon: ERHSApp.instagram,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple,
                                        Colors.purple,
                                        Colors.pink,
                                        Colors.red,
                                        Colors.orange,
                                        Colors.yellow,
                                      ],
                                    ),
                                    offset: Offset(2, -1.5),
                                  ),
                                  const SizedBox(width: 20),
                                  const Icon(ERHSApp.email, color: Colors.blue),
                                  const SizedBox(width: 20),
                                  const Icon(ERHSApp.link, color: Colors.blue),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
