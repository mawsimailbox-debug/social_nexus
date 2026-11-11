import 'package:flutter/material.dart';

abstract final class Tokens {
  static const canvas = Color(0xFFD1CFCB), canvasHi = Color(0xFFE9E7E3);
  static const ink = Color(0xFF262B2E),
      deep = Color(0xFF161A1C),
      soft = Color(0xFF1B2022);
  static const card = Color(0xFF22272A),
      card2 = Color(0xFF2A3034),
      pill = Color(0xFF4B4A4B);
  static const muted = Color(0xFF93928F),
      tan = Color(0xFFC2926B),
      alert = Color(0xFFFF453A);
  static const paper = Color(0xFFF4F2EE),
      line = Color(0xFFE3E0DA),
      surface = Color(0xFF14181A);
  static const photo = 'assets/baseline.jpg';
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: tan,
      secondary: tan,
      surface: card,
      error: alert,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 13.5, height: 1.45),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF272D31),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1D2225),
      showDragHandle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tan,
        foregroundColor: const Color(0xFF20150E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
