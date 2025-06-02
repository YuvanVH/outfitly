// Todo: Delete this file if not needed
// // lib/services/add_wardrobe_item.dart (optional, if I want to keep it)
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// Future<void> addWardrobeItem({
//   required String category,
//   required String color,
//   required String textDescriptionTitle,
//   required String imageUrl,
// }) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     throw Exception('User not logged in');
//   }
//   try {
//     await FirebaseFirestore.instance.collection('wardrobeItems').add({
//       'userId': user.uid,
//       'category': category,
//       'color': color,
//       'textDescriptionTitle': textDescriptionTitle,
//       'imageUrl': imageUrl,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//     debugPrint('Wardrobe item added');
//   } catch (e) {
//     debugPrint('Error adding wardrobe item: $e');
//     rethrow;
//   }
// }
