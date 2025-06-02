import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // För loggning

Future<User?> registerUser(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (e) {
    debugPrint(
      "Error registering user: $e",
    ); // Använd debugPrint istället för print
    return null;
  }
}
