// lib/models/outfit.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Outfit {
  final String id;
  final String userId;
  final List<String> itemIds; // References to wardrobeItems
  final String description;
  final DateTime createdAt;

  Outfit({
    required this.id,
    required this.userId,
    required this.itemIds,
    required this.description,
    required this.createdAt,
  });

  factory Outfit.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Outfit(
      id: documentId,
      userId: data['userId'] ?? '',
      itemIds: List<String>.from(data['itemIds'] ?? []),
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemIds': itemIds,
      'description': description,
      'createdAt': createdAt,
    };
  }
}
