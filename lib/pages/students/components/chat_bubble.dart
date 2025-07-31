import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 7.5, bottom: 7.5, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isCurrentUser ? Color.fromARGB(255, 3, 168, 244) : Colors.grey.shade500,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16),
        ),
    );
  }
}