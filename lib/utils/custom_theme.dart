import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color.fromARGB(255, 182, 216, 246),
    primaryColor: const Color.fromARGB(255, 149, 182, 209),
    primaryColorLight: const Color.fromARGB(255, 33, 150, 243),
    primaryColorDark: const Color.fromARGB(255, 0, 188, 212),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color.fromARGB(255, 58, 68, 87),
    primaryColor: const Color.fromARGB(255, 80, 92, 113),
    primaryColorLight: const Color.fromARGB(255, 19, 84, 136),
    primaryColorDark: const Color.fromARGB(255, 22, 68, 74),
  );
}
