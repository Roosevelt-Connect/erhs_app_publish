import 'chat_service.dart';
import 'components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String? receiverUserName; // made nullable so you can omit it
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    this.receiverUserName,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    _messageController.dispose();
    focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }

    scrollDown();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(38, 99, 202, 1),
                          Color.fromRGBO(58, 30, 136, 1)
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 40.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.15,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Expanded(child: _buildMessageList()),
                              _buildMessageInput(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: MediaQuery.of(context).size.width,
                                                    color: Colors.transparent,
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      width: MediaQuery.of(context).size.width/1.5,
                                                      child: Text(
                                                        widget.receiverUserName != null && widget.receiverUserName!.isNotEmpty
                                                            ? '${widget.receiverUserName} (${widget.receiverUserEmail})'
                                                            : widget.receiverUserEmail,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          color: Color.fromARGB(243, 248, 248, 248),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.arrow_back_ios_new_outlined,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
          widget.receiverUserID, _auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading messages');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading messages...');
        }

        final docs = snapshot.data!.docs;

        return ListView(
          controller: _scrollController,
          children:
              docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    final bool isCurrentUser = data['senderId'] == _auth.currentUser!.uid;

    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: Container(
        margin: isCurrentUser
            ? EdgeInsets.only(left: MediaQuery.of(context).size.width / 3)
            : EdgeInsets.only(right: MediaQuery.of(context).size.width / 3),
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 1),
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ChatBubble(
              message: data['message'],
              isCurrentUser: isCurrentUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.only(
            left: 10.0, top: 4.0, bottom: 4.0, right: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Message",
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
