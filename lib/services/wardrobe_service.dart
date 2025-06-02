import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/wardrobe_item.dart';

class WardrobeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> addWardrobeItem(WardrobeItem item) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    try {
      await _firestore.collection('wardrobeItems').add({
        'userId': userId,
        'category': item.category,
        'color': item.color,
        'textDescriptionTitle': item.textDescriptionTitle,
        'imageUrl': item.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'size': item.size,
        'isFavorite': item.isFavorite,
        'brand': item.brand,
      });
      debugPrint('Wardrobe item added');
    } catch (e) {
      debugPrint('Error adding wardrobe item: $e');
      rethrow;
    }
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

  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    try {
      await _firestore.collection('wardrobeItems').doc(itemId).update({
        'isFavorite': !isFavorite,
      });
      debugPrint('Favorite toggled for item: $itemId');
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }
}
