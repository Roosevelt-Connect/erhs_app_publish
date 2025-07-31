import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../students/components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:logger/logger.dart'; // Import logger package

class EducatorRegisterPage extends StatefulWidget {
  final Function()? onTap;
  const EducatorRegisterPage({super.key, required this.onTap});

  @override
  State<EducatorRegisterPage> createState() => _EducatorRegisterPageState();
}

class _EducatorRegisterPageState extends State<EducatorRegisterPage>
    with SingleTickerProviderStateMixin {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  final Logger logger = Logger();

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

  // Sign user up method
  Future<UserCredential?> signUserUp() async {
    if (!mounted) return null; // Guard against context being unmounted

    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Attempt to create user
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${emailController.text}@cnusd.k12.ca.us',
        password: passwordController.text,
      );

      if (!mounted) return null; // Ensure widget is still mounted

      // Close the loading circle
      Navigator.pop(context);

      // Save user info to Firestore
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': '${emailController.text}@cnusd.k12.ca.us',
      }, SetOptions(merge: false));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return null; // Ensure widget is still mounted

      // Close the loading circle
      Navigator.pop(context);

      // Log the error with logger
      logger.e('Firebase Auth Exception: ${e.message}', e);
      return null;
    } catch (e) {
      if (!mounted) return null; // Ensure widget is still mounted

      // Close the loading circle
      Navigator.pop(context);

      // Log unexpected error
      logger.e('Unexpected error: $e');
      return null;
    }
  }

  // Error message popups
  void showErrorDialog(String message) {
    if (!mounted) {
      return; // Ensure widget is still mounted before showing dialog
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 60),
                      child: Center(
                        child: Icon(
                          Icons.lock_open,
                          size: 200,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, 130),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 100,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                    AppBar(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      iconTheme: IconThemeData(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    Transform.translate(
                      offset: const Offset(0, 25),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 120.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
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
                                    const SizedBox(height: 20),
                                    MyTextField(
                                      controller: confirmPasswordController,
                                      hintText: 'Confirm Password',
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 10),
                                    const SizedBox(height: 25),
                                    MyButton(
                                      text: "Sign Up",
                                      onTap: () async {
                                        var userCredential = await signUserUp();
                                        if (userCredential == null) {
                                          showErrorDialog(
                                              'Something went wrong.');
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account?  ',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: widget.onTap,
                                            child: Text(
                                              'Login now',
                                              style: TextStyle(
                                                color: Colors.blue.shade900,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Container(
                  height: MediaQuery.of(context).size.height / 5.0,
                  width: width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: const [
                            Color.fromRGBO(230, 159, 5, 1),
                            Color.fromRGBO(204, 45, 16, 1)
                          ],
                          begin: _topAlignmentAnimation.value,
                          end: _bottomAlignmentAnimation.value),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.elliptical(200, 105.0))),
                );
              }),
        ],
      ),
    );
  }
}
