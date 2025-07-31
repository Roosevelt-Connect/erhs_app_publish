import '../../../main.dart';
import '../../../models/customicons.dart';
import '../id.dart';
import '../settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();

    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
    print(e);
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
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
    } catch (e) {
      // Handle exceptions
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
                  title: const Text("D I G I T A L  I D"),
                  leading: const Icon(ERHSApp.license),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyIdPage()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("S E T T I N G S"),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
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
                                      'If you select "Delete," this will \ndelete your account.' ,
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
                              child: const Text(
                                'Delete',
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
              const SizedBox(height: 35.0),
            ],
          )
        ],
      ),
    );
  }
}