import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeItem {
  final String id;
  final String userId;
  final String category;
  final String color;
  final String textDescriptionTitle;
  final String imageUrl;
  final DateTime createdAt;
  final String size; // New field
  final bool isFavorite; // New field
  final String brand; // New field

  WardrobeItem({
    required this.id,
    required this.userId,
    required this.category,
    required this.color,
    required this.textDescriptionTitle,
    required this.imageUrl,
    required this.createdAt,
    required this.size,
    this.isFavorite = false,
    required this.brand,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'color': color,
      'textDescriptionTitle': textDescriptionTitle,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'size': size,
      'isFavorite': isFavorite,
      'brand': brand,
    };
  }

  factory WardrobeItem.fromFirestore(Map<String, dynamic> data, String id) {
    return WardrobeItem(
      id: id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      color: data['color'] ?? '',
      textDescriptionTitle: data['textDescriptionTitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      size: data['size'] ?? 'Unknown',
      isFavorite: data['isFavorite'] ?? false,
      brand: data['brand'] ?? 'Other',
    );
  }
}
