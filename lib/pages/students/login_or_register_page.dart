import 'login_page.dart';
import 'register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
      print('Toggled! Now showLoginPage: $showLoginPage');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        key: UniqueKey(), // <-- Add this line
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        key: UniqueKey(), // <-- Add this line
        onTap: togglePages,
      );
    }
  }
}
