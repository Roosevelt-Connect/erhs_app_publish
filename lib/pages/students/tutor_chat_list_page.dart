import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';

class TutorChatListPage extends StatefulWidget {
  const TutorChatListPage({super.key});

  @override
  State<TutorChatListPage> createState() => _TutorChatListPageState();
}

class _TutorChatListPageState extends State<TutorChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _fireStore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        userDoc = await _fireStore.collection('students').doc(uid).get();
      }

      if (!userDoc.exists) {
        print("User with UID $uid not found.");
        return null;
      }

      final String? email = (userDoc['email']  ?? userDoc['mail']) + "@students.cnusd.k12.ca.us";
      if (email == null || email.isEmpty) {
        print("Email not found for UID $uid.");
        return null;
      }

      final QuerySnapshot tutorSnapshot = await _fireStore
          .collection('tutor')
          .where('mail', isEqualTo: email)
          .limit(1)
          .get();

      if (tutorSnapshot.docs.isNotEmpty) {
        final tutorData =
            tutorSnapshot.docs.first.data() as Map<String, dynamic>;
        print('Fetched tutor data for UID $uid: $tutorData');
        return tutorData;
      } else {
        print("Tutor not found with mail: $email");
        return null;
      }
    } catch (e) {
      print("Error fetching tutor details for $uid: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Conversations")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('chat_rooms')
            .where('participants', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no conversations yet.'));
          }

          List<DocumentSnapshot> chatRoomDocs = snapshot.data!.docs;

          chatRoomDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final tsA = dataA['lastMessageTimestamp'] as Timestamp?;
            final tsB = dataB['lastMessageTimestamp'] as Timestamp?;
            if (tsA == null && tsB == null) return 0;
            if (tsA == null) return 1;
            if (tsB == null) return -1;
            return tsB.compareTo(tsA);
          });

          return ListView(
            children: chatRoomDocs.map((doc) {
              final chatRoomData = doc.data() as Map<String, dynamic>;
              final List<dynamic> participants =
                  chatRoomData['participants'] ?? [];

              if (participants.length < 2) return const SizedBox.shrink();

              final String otherUserId = participants
                  .firstWhere((id) => id != currentUser.uid, orElse: () => '');

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserDetails(otherUserId),
                builder: (context, userSnapshot) {
                  String displayName = "User";
                  String tutorEmail = "unknown@example.com";

                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    displayName = "Loading...";
                  } else if (userSnapshot.hasError) {
                    displayName = "Error";
                    tutorEmail = "Error";
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data != null) {
                    final data = userSnapshot.data!;
                    final String? name = data['name'] as String?;
                    final String? mail = data['mail'] as String?;

                    if (name != null && name.isNotEmpty) {
                      displayName = name;
                    }

                    if (mail != null && mail.isNotEmpty) {
                      tutorEmail = mail;
                    }

                    print(
                        'Final tutor: $displayName, Email: $tutorEmail, UID: $otherUserId');
                  }

                  return ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Center(
                        child: Text(displayName, textAlign: TextAlign.center)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (tutorEmail == "unknown@example.com" ||
                          tutorEmail == "Error") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Cannot open chat: user contact info unavailable."),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiverUserID: otherUserId,
                            receiverUserEmail: tutorEmail,
                            receiverUserName: displayName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
