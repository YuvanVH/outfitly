import 'package:flutter/material.dart';

class StandardButtonStyles {
  static ButtonStyle defaultStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 172, 141, 231),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      foregroundColor: Colors.white,
      elevation: 3,
    );
  }
}
