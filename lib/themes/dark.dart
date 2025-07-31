import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 39, 39, 39),
    primary: Colors.white,
    secondary: Colors.grey.shade700,
    tertiary: const Color.fromARGB(255, 52, 52, 52),
    inversePrimary: Colors.grey.shade300,
    inverseSurface: const Color.fromARGB(255, 20, 20, 20),
    brightness: Brightness.dark,
  ),
  fontFamily: 'Kanit',
);