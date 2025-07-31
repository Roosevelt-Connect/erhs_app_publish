import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Color.fromRGBO(68, 94, 145, 1),
    secondary: Color.fromARGB(255, 138, 140, 142),
    tertiary: Color.fromARGB(243, 248, 248, 248),
    inversePrimary: Colors.grey.shade900,
    inverseSurface: Color.fromARGB(255, 245, 244, 244),
    brightness: Brightness.light,
  ),
  fontFamily: 'Kanit',
);


// ThemeData lightMode = ThemeData(
//   fontFamily: 'Kanit',
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: const Color.fromARGB(255, 20, 40, 75)
//   ),
//   useMaterial3: true,
// );