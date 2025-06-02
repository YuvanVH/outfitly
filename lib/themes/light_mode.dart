import 'package:flutter/material.dart';

// TODO: Delete colors not needed in the end
ThemeData lightMode = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 150, 99, 233),
    onPrimary: Colors.white,
    secondary: Color(0xFF03DAC6),
    onSecondary: Colors.black,
    surface: Colors.white,
    onSurface: Color.fromARGB(255, 63, 63, 63),
    error: Colors.red,
    onError: Colors.white,
    primaryContainer: Color.fromARGB(255, 204, 171, 244),
    onPrimaryContainer: Colors.black,
    secondaryContainer: Color(0xFFE0F7FA),
    onSecondaryContainer: Colors.black,
    onSurfaceVariant: Colors.black,
    outline: Color.fromARGB(255, 224, 224, 224),
    outlineVariant: Color(0xFFE0E0E0),
    shadow: Color(0x33000000),
    inverseSurface: Color(0xFF121212),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFF3700B3),
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 247, 247, 247),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Color.fromARGB(255, 255, 255, 255),
    elevation: 12,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
  ),
);
