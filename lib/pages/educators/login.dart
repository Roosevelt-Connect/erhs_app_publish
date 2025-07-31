import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../students/components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class EducatorLoginPage extends StatefulWidget {
  const EducatorLoginPage({super.key});


  @override
  State<EducatorLoginPage> createState() => _EducatorLoginPageState();
}

class _EducatorLoginPageState extends State<EducatorLoginPage>
    with SingleTickerProviderStateMixin {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Logger for logging
  var logger = Logger();

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

  // sign user in method
Future<UserCredential?> signUserIn() async {
  if (!mounted) return null;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "${emailController.text}@cnusd.k12.ca.us",
      password: passwordController.text,
    );

    if (!mounted) return null;
    Navigator.pop(context);

    _fireStore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': emailController.text,
    }, SetOptions(merge: true));

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (!mounted) return null;
    Navigator.pop(context);

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

    logger.e('FirebaseAuthException: $errorMsg');
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

    return null;
  }
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
                              Transform.translate(
                                offset: const Offset(0, 110),
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
                              Transform.translate(
                                offset: const Offset(0, 75),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 120.0),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: Column(
                                            children: [
                                              EmailField(
                                                controller: emailController,
                                                hintText: 'Name',
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
                                            ],
                                          ),
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
