import 'educator_agenda.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EducatorAuthPage extends StatelessWidget {
  EducatorAuthPage({super.key});
  // List of approved educator emails
  final List<String> approved = [
    'counselor1@cnusd.k12.ca.us'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (approved.contains(FirebaseAuth.instance.currentUser!.email)) {
              return EducatorAgenda();
            } else {
              // If the user is logged in but not an approved educator, show an error message
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text('Access Denied'),
                ),
                body: Center(
                  child: Text(
                    'You do not have permission to access this page.',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              );
            }
          }
          return EducatorLoginPage();
        },
      ),
    );
  }
}
