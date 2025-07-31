import 'chat_page.dart';
import 'chat_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MaterialApp(
    home: MessagingApp(),
  ));
}

class MessagingApp extends StatefulWidget {
  const MessagingApp({super.key});

  @override
  _MessagingAppState createState() => _MessagingAppState();
}

class _MessagingAppState extends State<MessagingApp> {
  final List<String> messages = [];
  final TextEditingController controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Search Clubs...');
  bool search = false;
  Stream? chatRoomStream;
  
  List<String> searchTerms = [
    "counselor1@cnusd.k12.ca.us",
    "counselor2@cnusd.k12.ca.us",
    "counselor3@cnusd.k12.ca.us",
    "newteacher1@cnusd.k12.ca.us",
  ];

  var ids = {
    'counselor1@cnusd.k12.ca.us': 'oG3wE5FeBsPhblfpd07FkbQP11k2',
    'counselor2@cnusd.k12.ca.us': 'tdoDfwwzaRVCkIAWB7qo4d4RwxS2',
    'counselor3@cnusd.k12.ca.us': 'Ky7zSdB6VcZqeSqe4s6GxZpJd172',
    'newteacher1@cnusd.k12.ca.us': '2c0ymMKPNKS9TYQWMOJZyi2hBXq2',
  };

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        _buildUserList();
      });
    }
    setState(() {
      search = true;
    });
    if (_messageController.text.isNotEmpty) {
      List<String> matchQuery = [];
      for (var person in searchTerms) {
        if (person.toLowerCase().contains(_messageController.text.toLowerCase())) {
          matchQuery.add(person);
        }
      }

      return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          String result = matchQuery[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: result,
                    receiverUserID: ids[result]!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.5,
                        height: 42.5,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(60)
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 28,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width/1.25,
                        child: Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                  child: Text(
                                    result,
                                    style: const TextStyle(
                                      fontSize: 16
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                  child: StreamBuilder(
                                    stream: _chatService.getMessages(
                                      ids[result]!, _auth.currentUser!.uid
                                    ), 
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return const Text('error');
                                      }
                                                                      
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('Loading...');
                                      }
                                                                      
                                      if (snapshot.data!.docs.isNotEmpty) {
                                          return Text(
                                            _buildDateItem(snapshot.data!.docs.last),
                                            style: const TextStyle(
                                              fontSize: 12.5
                                            ),
                                        );
                                      }
                                      return const Text("");
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                  child: StreamBuilder(
                                    stream: _chatService.getMessages(
                                      ids[result]!, _auth.currentUser!.uid
                                    ), 
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return const Text('error');
                                      }
                                  
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('Loading...');
                                      }
                                  
                                      if (snapshot.data!.docs.isNotEmpty) {
                                          return Text(
                                          _buildLastMessageItem(snapshot.data!.docs.last),
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }
                                      return const Text("");
                                    },
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ),
          );
        },
      );
    }
    return _buildUserList();
  }

  void sendMessage() {
    if (controller.text.isNotEmpty) {
      setState(() {
        messages.add(controller.text);
        controller.clear();
      });
    }
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return search? Scaffold(
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color: Colors.blue[900],
        height: 200,
        backgroundColor: Colors.blue[600],
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color.fromRGBO(200, 140, 20, 1), Color.fromRGBO(173, 58, 37, 1)], begin: Alignment.topRight, end: Alignment.topLeft)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 40.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/1.15,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: initiateSearch(_messageController.text)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _messageController.text = "";
                                  search = false;
                                });
                              }
                            ),
                            const SizedBox(
                              width: 15.0
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Counselors...',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500
                                ),
                                onChanged: (value) {
                                  initiateSearch(value);
                                },
                              )
                            ),
                            GestureDetector(
                              onTap: () {
                                _messageController.text = "";
                                initiateSearch(_messageController.text);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60)
                                ),
                                child: const Icon(
                                  Icons.clear,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ) : LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: Colors.blue[900],
      height: 200,
      backgroundColor: Colors.blue[600],
      animSpeedFactor: 2,
      showChildOpacityTransition: false,
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color.fromRGBO(200, 140, 20, 1), Color.fromRGBO(173, 58, 37, 1)], begin: Alignment.topRight, end: Alignment.topLeft)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 40.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/1.15,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildUserList()
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5.0),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            color: Colors.transparent,
                                            child: const Text(
                                              textAlign: TextAlign.center,
                                              "Counselors",
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Color.fromARGB(243, 248, 248, 248)
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 200,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              search = !search;
                                              setState(() {
                                                
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(60)
                                              ),
                                              child: const Icon(
                                                Icons.search,
                                                size: 25,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
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
                                  }
                                ),
                              ],
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Lottie.asset(
                    'lib/assets/animations/loading_book.json',
                    repeat: true
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          // padding: const EdgeInsets.all(8),
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      receiverUserEmail: "counselor1@cnusd.k12.ca.us",
                      receiverUserID: "oG3wE5FeBsPhblfpd07FkbQP11k2",
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.5,
                          height: 42.5,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(60)
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width/1.25,
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: Text(
                                      "counselor1@cnusd.k12.ca.us",
                                      style: TextStyle(
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "oG3wE5FeBsPhblfpd07FkbQP11k2", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                                                        
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                                                        
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                              _buildDateItem(snapshot.data!.docs.last),
                                              style: const TextStyle(
                                                fontSize: 12.5
                                              ),
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "oG3wE5FeBsPhblfpd07FkbQP11k2", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                    
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                    
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                            _buildLastMessageItem(snapshot.data!.docs.last),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      receiverUserEmail: "counselor2@cnusd.k12.ca.us",
                      receiverUserID: "tdoDfwwzaRVCkIAWB7qo4d4RwxS2",
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.5,
                          height: 42.5,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(60)
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width/1.25,
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: Text(
                                      "counselor2@cnusd.k12.ca.us",
                                      style: TextStyle(
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "tdoDfwwzaRVCkIAWB7qo4d4RwxS2", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                                                        
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                                                        
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                              _buildDateItem(snapshot.data!.docs.last),
                                              style: const TextStyle(
                                                fontSize: 12.5
                                              ),
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "tdoDfwwzaRVCkIAWB7qo4d4RwxS2", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                    
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                    
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                            _buildLastMessageItem(snapshot.data!.docs.last),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      receiverUserEmail: "counselor3@cnusd.k12.ca.us",
                      receiverUserID: "Ky7zSdB6VcZqeSqe4s6GxZpJd172",
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.5,
                          height: 42.5,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(60)
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width/1.25,
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: Text(
                                      "counselor3@cnusd.k12.ca.us",
                                      style: TextStyle(
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "Ky7zSdB6VcZqeSqe4s6GxZpJd172", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                                                        
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                                                        
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                              _buildDateItem(snapshot.data!.docs.last),
                                              style: const TextStyle(
                                                fontSize: 12.5
                                              ),
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "Ky7zSdB6VcZqeSqe4s6GxZpJd172", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                    
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                    
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                            _buildLastMessageItem(snapshot.data!.docs.last),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      receiverUserEmail: "newteacher1@cnusd.k12.ca.us",
                      receiverUserID: "2c0ymMKPNKS9TYQWMOJZyi2hBXq2",
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.5,
                          height: 42.5,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(60)
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width/1.25,
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: Text(
                                      "newteacher1@cnusd.k12.ca.us",
                                      style: TextStyle(
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "2c0ymMKPNKS9TYQWMOJZyi2hBXq2", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                                                        
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                                                        
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                              _buildDateItem(snapshot.data!.docs.last),
                                              style: const TextStyle(
                                                fontSize: 12.5
                                              ),
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                    child: StreamBuilder(
                                      stream: _chatService.getMessages(
                                        "2c0ymMKPNKS9TYQWMOJZyi2hBXq2", _auth.currentUser!.uid
                                      ), 
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('error');
                                        }
                                    
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                    
                                        if (snapshot.data!.docs.isNotEmpty) {
                                            return Text(
                                            _buildLastMessageItem(snapshot.data!.docs.last),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
          ],
        );
      }
    );
  }
}

String _buildDateItem(DocumentSnapshot document) {
  Map <String, dynamic> data = document.data() as Map <String, dynamic>;

  String output;
  DateTime dt = (data['timestamp'] as Timestamp).toDate();
  int today = DateTime.now().day;

  if (dt.day - today != 0) {
    output = DateFormat('MM/dd/yyyy').format(dt); // 31/12/2000
  } else {
    output = DateFormat('hh:mm a').format(dt); // 22:00
  }
  
  return output;
}

String _buildLastMessageItem(DocumentSnapshot document) {
  Map <String, dynamic> data = document.data() as Map <String, dynamic>;
  if (data['message'] == null) {
    return "";
  }
  return data['message'];
}