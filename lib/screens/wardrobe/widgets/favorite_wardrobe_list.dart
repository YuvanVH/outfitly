import 'package:flutter/material.dart';
import '../../../models/wardrobe_item.dart';
import '../../../services/wardrobe_service.dart';
import 'edit_item_dialog.dart';

class FavoriteWardrobeList extends StatelessWidget {
  final List<WardrobeItem> favorites;
  final WardrobeService wardrobeService;
  final VoidCallback onChanged;

  const FavoriteWardrobeList({
    super.key,
    required this.favorites,
    required this.wardrobeService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 400;
    final cardWidth = isMobile ? 120.0 : (screenWidth > 600 ? 200.0 : 160.0);
    // Dynamisk höjd baserat på innehåll
    const cardHeightBase = 120.0;
    const imageHeight = 80.0;

    if (favorites.isEmpty) {
      return const Text('No favorites yet.');
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 16 : 0),
        child: SizedBox(
          height: cardHeightBase, // Fixad höjd för horisontell scroll
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            clipBehavior: Clip.none,
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: cardWidth,
                  constraints: const BoxConstraints(maxWidth: 200.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(51),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [Colors.purple[50]!, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            height: imageHeight,
                            width: cardWidth - 16,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                'Image load failed for URL: ${item.imageUrl}, Error: $error',
                              );
                              return Image.asset(
                                'web/assets/icons/default_item_image.png',
                                height: imageHeight,
                                width: cardWidth - 16,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.textDescriptionTitle,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isMobile ? 10 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${item.category} | ${item.color}',
                                style: TextStyle(fontSize: isMobile ? 8 : 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: item.isFavorite ? 1.2 : 1.0,
                              child: IconButton(
                                icon: Icon(
                                  item.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: item.isFavorite
                                      ? const Color.fromARGB(
                                          255,
                                          177,
                                          82,
                                          255,
                                        )
                                      : Theme.of(context).colorScheme.secondary,
                                  size: isMobile ? 16 : 20,
                                ),
                                onPressed: () async {
                                  await wardrobeService.toggleFavorite(
                                    item.id,
                                    item.isFavorite,
                                  );
                                  onChanged();
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.secondary,
                                size: isMobile ? 16 : 20,
                              ),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) => EditItemDialog(
                                    item: item,
                                    onSave: onChanged,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.secondary,
                                size: isMobile ? 16 : 20,
                              ),
                              onPressed: () async {
                                await wardrobeService.deleteWardrobeItem(
                                  item.id,
                                );
                                onChanged();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
