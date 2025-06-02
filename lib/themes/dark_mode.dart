import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFBB86FC),
    onPrimary: Colors.black,
    secondary: Color(0xFF03DAC6),
    onSecondary: Colors.black,
    surface: Color(0xFF121212),
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.black,
    primaryContainer: Color.fromARGB(255, 114, 27, 190),
    onPrimaryContainer: Colors.white,
    secondaryContainer: Color(0xFF005457),
    onSecondaryContainer: Colors.white,
    onSurfaceVariant: Colors.white,
    outline: Color(0xFF666666),
    outlineVariant: Color(0xFF2C2C2C),
    shadow: Colors.black,
    inverseSurface: Colors.white,
    onInverseSurface: Colors.black,
    inversePrimary: Color(0xFF6200EE),
  ),
  scaffoldBackgroundColor: Color(0xFF000000),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Color(0xFF1C1C1C),
    elevation: 12,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
  ),
);
