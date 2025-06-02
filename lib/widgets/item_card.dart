// lib/widgets/item_card.dart
import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';

class ItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onDelete;

  const ItemCard({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Image.network(item.imageUrl, height: 50, fit: BoxFit.cover),
        title: Text(
          item.textDescriptionTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
