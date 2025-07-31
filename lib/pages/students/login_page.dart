import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      )
    ]).animate(_animationController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      )
    ]).animate(_animationController);

    _animationController.repeat();
  }

  Future<UserCredential> signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${emailController.text}@students.cnusd.k12.ca.us",
        password: passwordController.text,
      );

      // pop the loading circle
      Navigator.pop(context);

      // Print UID and Email on successful login
      print('User UID: ${userCredential.user!.uid}');
      print('User Email: ${userCredential.user!.email}');

      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': emailController.text,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      // Print error message for debugging
      String errorMsg = '';
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No user found with that email.';
          break;
        case 'wrong-password':
          errorMsg = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMsg = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMsg = 'This account has been disabled.';
          break;
        default:
          errorMsg = e.message ?? 'An unknown error occurred.';
      }
      
      print(e.message);
      showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade600,
          title: const Text(
            'Login Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            errorMsg,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
      throw Exception(e.code);
    }
  }

  // wrong email message popup
  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepOrange,
          title: Center(
            child: Text(
              'Incorrect Email',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // wrong password message popup
  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepOrange,
          title: Center(
            child: Text(
              'Incorrect Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Removed Transform.translate, just use Padding for positioning
                              Padding(
                                padding: const EdgeInsets.only(top: 110.0),
                                child: Center(
                                  child: Icon(
                                    Icons.lock,
                                    size: 200,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                              ),
                              AppBar(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                iconTheme: IconThemeData(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                              // Removed Transform.translate, just use Padding for positioning
                              Padding(
                                padding: const EdgeInsets.only(top: 195.0),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 20.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Column(
                                          children: [
                                            EmailField(
                                              controller: emailController,
                                              hintText: '6-Digit ID',
                                              obscureText: false,
                                            ),
                                            const SizedBox(height: 20),
                                            MyTextField(
                                              controller: passwordController,
                                              hintText: 'Password',
                                              obscureText: true,
                                            ),
                                            const SizedBox(height: 10),
                                            MyButton(
                                              text: "Sign In",
                                              onTap: signUserIn,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 25),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Not a member?  ',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: widget.onTap,
                                                    child: Text(
                                                      'Register now',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .blue.shade900,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) {
                        return Container(
                          height: height / 5.0,
                          width: width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Color.fromRGBO(38, 99, 202, 1),
                                Color.fromRGBO(76, 35, 147, 1),
                              ],
                              begin: _topAlignmentAnimation.value,
                              end: _bottomAlignmentAnimation.value,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.elliptical(200, 105.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
