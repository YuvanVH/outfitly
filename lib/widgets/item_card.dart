// lib/widgets/item_card.dart
import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';

class ItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onDelete;
  final VoidCallback? onToggleFavorite; // New callback

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onToggleFavorite,
  });

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
        subtitle: Text(
          'Category: ${item.category} | Color: ${item.color} | Size: ${item.size} | Brand: ${item.brand}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color:
                    item.isFavorite
                        ? Colors.red
                        : Theme.of(context).colorScheme.secondary,
              ),
              onPressed: onToggleFavorite,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
