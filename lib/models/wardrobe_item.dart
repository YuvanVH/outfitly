import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeItem {
  final String id;
  final String userId;
  final String category;
  final String color;
  final String textDescriptionTitle;
  final String imageUrl;
  final DateTime createdAt;

  WardrobeItem({
    required this.id,
    required this.userId,
    required this.category,
    required this.color,
    required this.textDescriptionTitle,
    required this.imageUrl,
    required this.createdAt,
  });

  // Konvertera från Firestore-dokument till WardrobeItem
  factory WardrobeItem.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return WardrobeItem(
      id: documentId,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      color: data['color'] ?? '',
      textDescriptionTitle: data['textDescriptionTitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Konvertera WardrobeItem till Firestore-format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'color': color,
      'textDescriptionTitle': textDescriptionTitle,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
