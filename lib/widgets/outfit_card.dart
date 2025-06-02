// lib/widgets/outfit_card.dart
import 'package:flutter/material.dart';
import '../models/outfit.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;

  const OutfitCard({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(outfit.description),
        subtitle: Text('Items: ${outfit.itemIds.length}'),
      ),
    );
  }
}
