import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Register a new user
  Future<User?> registerUser(
    String email,
    String password,
    String firstName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        final userModel = UserModel(
          userId: user.uid,
          email: user.email ?? email,
          firstName: firstName,
        );
        // Set user data in Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }
      debugPrint('Registered user: ${user?.uid}');
      return user;
    } catch (e) {
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Signed in user: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      // Delete wardrobe items
      final wardrobeItems =
          await _firestore
              .collection('wardrobeItems')
              .where('userId', isEqualTo: userId)
              .get();
      for (var doc in wardrobeItems.docs) {
        await doc.reference.delete();
      }

      // Delete profile image from storage
      try {
        await _storage.ref('profile_images/$userId.jpg').delete();
      } catch (e) {
        debugPrint('No profile image to delete or error: $e');
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Delete Firebase Auth user
      await _auth.currentUser?.delete();

      debugPrint('User account deleted: $userId');
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  // Change user password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      debugPrint('Password updated for user: ${user.uid}');
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  // Change user email
  Future<void> changeEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update email in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });

      debugPrint('Email updated for user: ${user.uid} to $newEmail');
    } catch (e) {
      debugPrint('Error changing email: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fetch user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  // Upload profile image and update user profile
  Future<String?> uploadProfileImage(
    Uint8List imageBytes,
    String userId,
  ) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'profileImage': downloadUrl,
      });

      debugPrint('Profile image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }
}
