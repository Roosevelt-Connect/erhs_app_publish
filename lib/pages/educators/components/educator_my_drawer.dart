import '../../../main.dart';
import '../scan_id.dart';
import '../../students/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Import the logger package

class EducatorMyDrawer extends StatefulWidget {
  const EducatorMyDrawer({super.key});

  @override
  State<EducatorMyDrawer> createState() => _EducatorMyDrawerState();
}

class _EducatorMyDrawerState extends State<EducatorMyDrawer> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger logger = Logger(); // Initialize logger

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
      if (mounted) {
        // Check if the widget is still mounted
        Navigator.pop(context); // Use BuildContext safely
      }
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException: ${e.message}',
          e); // Log the error with logger

      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      logger.e('General exception: $e'); // Log general errors
      // Handle general exception
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData = _firebaseAuth.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await _firebaseAuth.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _firebaseAuth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await _firebaseAuth.currentUser?.delete();

      if (mounted) {
        // Check if the widget is still mounted
        Navigator.pop(context); // Use BuildContext safely
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } catch (e) {
      logger
          .e('Reauthentication error: $e'); // Log error during reauthentication
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Image.asset(
                  "lib/assets/img/erhs_logo.png",
                  width: 150,
                  height: 100,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("H O M E"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("S C A N  I D"),
                  leading: const Icon(Icons.barcode_reader),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ScanPage()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("S E T T I N G S"),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()));
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("D E L E T E  A C C O U N T"),
                  leading: const Icon(Icons.delete),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete your Account?'),
                          content: const SizedBox(
                            height: 150,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'If you select "Delete", this will \ndelete your account.',
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    Spacer(),
                                    Text("\n\n")
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Are you sure you want to \ndelete your account?",
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    Spacer(),
                                    Text("\n\n")
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "This action is permenant.",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                deleteUserAccount();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("L O G O U T"),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    signUserOut();
                  },
                ),
              ),
              const SizedBox(
                height: 35.0,
              ),
            ],
          )
        ],
      ),
    );
  }
}
