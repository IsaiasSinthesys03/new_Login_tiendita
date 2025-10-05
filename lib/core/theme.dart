import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const militaryGreen = Color(0xFF2E3B2F); // “verde militar” para appbar
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF2D5BFF),
    scaffoldBackgroundColor: const Color(0xFFF2F4F7),
    appBarTheme: const AppBarTheme(
      backgroundColor: militaryGreen,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
  );
}
