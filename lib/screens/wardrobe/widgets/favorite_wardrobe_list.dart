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
    final cardWidth = isMobile ? 150.0 : (screenWidth > 600 ? 260.0 : 200.0);
    final cardHeight = isMobile ? 120.0 : (screenWidth > 600 ? 220.0 : 170.0);

    if (favorites.isEmpty) {
      return const Text('No favorites yet.');
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 16 : 0), // Mer luft nertill
        child: SizedBox(
          height:
              cardHeight +
              (isMobile ? 16 : 0), // Extra höjd för säkerhets skull
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
                  height: cardHeight,
                  clipBehavior: Clip.none,
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
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: Offset(index * 0.2, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Viktigt!
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl, // <--- här!
                              height: isMobile ? 50 : 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  'Image load failed for URL: ${item.imageUrl}, Error: $error',
                                );
                                return Image.asset(
                                  'web/assets/icons/default_item_image.png',
                                  height: isMobile ? 50 : 80,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.textDescriptionTitle,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category} | ${item.color}',
                            style: TextStyle(fontSize: isMobile ? 10 : 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: isMobile ? 8 : 12,
                          ), // Ersätter Spacer
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
                                    color:
                                        item.isFavorite
                                            ? const Color.fromARGB(
                                              255,
                                              177,
                                              82,
                                              255,
                                            )
                                            : Theme.of(
                                              context,
                                            ).colorScheme.secondary,
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: isMobile ? 16 : 20,
                                ),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder:
                                        (context) => EditItemDialog(
                                          item: item,
                                          onSave: onChanged,
                                        ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
