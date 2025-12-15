import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF2563EB),
      secondary: Colors.blueAccent,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white70,
      foregroundColor: Colors.black87,
      centerTitle: false,
    ),
    textTheme: base.textTheme.apply(fontFamily: 'Inter'),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
  );
}
