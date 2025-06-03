// lib/widgets/item_card.dart
import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';
import '../screens/wardrobe/widgets/edit_item_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onDelete;
  final VoidCallback? onToggleFavorite;

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // Inside ItemCard's ListTile -> leading
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) {
              debugPrint('Image load failed for URL: $url, Error: $error');
              return Image.asset(
                'web/assets/icons/default_item_image.png',
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Default image failed to load: $error');
                  return const Icon(Icons.image_not_supported, size: 50);
                },
              );
            },
          ),
        ),
        title: Text(
          item.textDescriptionTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Category: ${item.category} | Color: ${item.color} | Size: ${item.size} | Brand: ${item.brand}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: item.isFavorite ? 1.2 : 1.0,
              child: IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      item.isFavorite
                          ? const Color.fromARGB(255, 194, 82, 255)
                          : Theme.of(context).colorScheme.secondary,
                ),
                onPressed: onToggleFavorite,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder:
                      (context) => EditItemDialog(
                        item: item,
                        onSave: () {
                          // Låt föräldern (WardrobeScreen) hantera UI-uppdatering via callback
                        },
                      ),
                );
              },
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
