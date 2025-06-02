import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/wardrobe_item.dart';

class WardrobeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // In wardrobe_service.dart
  Future<void> addWardrobeItem(WardrobeItem item) async {
    await FirebaseFirestore.instance.collection('wardrobeItems').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'category': item.category,
      'color': item.color,
      'textDescriptionTitle': item.textDescriptionTitle,
      'imageUrl': item.imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<WardrobeItem>> getWardrobeItems() async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    try {
      final querySnapshot =
          await _firestore
              .collection('wardrobeItems')
              .where('userId', isEqualTo: _userId)
              .orderBy('createdAt', descending: true)
              .get();
      return querySnapshot.docs.map((doc) {
        return WardrobeItem.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching wardrobe items: $e');
      rethrow;
    }
  }

  Future<void> deleteWardrobeItem(String itemId) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    try {
      await _firestore.collection('wardrobeItems').doc(itemId).delete();
      debugPrint('Wardrobe item deleted');
    } catch (e) {
      debugPrint('Error deleting wardrobe item: $e');
      rethrow;
    }
  }
}
