import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId : currentUserId,
      senderEmail : currentUserEmail,
      receiverId : receiverId,
      message : message,
      timestamp : timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join(
      "_"
    );

    // Add/update the chat room document with participants and last message timestamp
    await _fireStore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': ids, // Store both UIDs
      'lastMessageTimestamp': timestamp, // For sorting chat rooms
      // You can also store lastMessageText here if needed for previews
    }, SetOptions(merge: true)); // Use merge to not overwrite the messages subcollection

    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
  }

  Stream <QuerySnapshot> getMessages(String userId, String otherUserId) {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");
      return _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
    }
}