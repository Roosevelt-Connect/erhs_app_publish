import '../../../models/customicons.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.focusNode,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  IconData icon = Icons.remove_red_eye_outlined;
  var isObscured;
  @override
  void initState() {
    super.initState();

    isObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          fontFamily: 'Kanit',
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 20, 40, 75)),
          useMaterial3: true,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: TextField(
            controller: widget.controller,
            obscureText: isObscured,
            focusNode: widget.focusNode,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            cursorColor: Theme.of(context).colorScheme.inversePrimary,
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isObscured = !isObscured;
                    });
                    if (!isObscured) {
                      icon = ERHSApp.eye_off;
                    } else {
                      icon = Icons.remove_red_eye_outlined;
                    }
                  },
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                )),
          ),
        ));
  }
}

class EmailField extends StatelessWidget {
  final controller; //string
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;

  const EmailField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        fontFamily: 'Kanit',
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 20, 40, 75)),
        useMaterial3: true,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          focusNode: focusNode,
          cursorColor: Theme.of(context).colorScheme.inversePrimary,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            hintText: hintText,
            hintStyle:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            suffix: Text(
              "@cnusd.k12.ca.us",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ),
      ),
    );
  }
}
