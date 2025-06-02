import 'package:flutter/material.dart';
import '../../../models/wardrobe_item.dart';
import '../../../services/wardrobe_service.dart';
import '../../../widgets/item_card.dart';
import '../../../widgets/nav_bars/dynamic_desktop_title.dart';
import '../../../widgets/nav_bars/dynamic_mobile_appbar_title.dart';

class ClothsItemScreen extends StatefulWidget {
  const ClothsItemScreen({super.key});

  @override
  ClothsItemScreenState createState() => ClothsItemScreenState();
}

class ClothsItemScreenState extends State<ClothsItemScreen> {
  final WardrobeService _wardrobeService = WardrobeService();
  late Future<List<WardrobeItem>> _wardrobeItems;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchWardrobeItems();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _fetchWardrobeItems() {
    _wardrobeItems = _wardrobeService.getWardrobeItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const DynamicMobileAppBarTitle()),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) const DynamicDesktopTitle(),
            const SizedBox(height: 32),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<WardrobeItem>>(
                future: _wardrobeItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No items in wardrobe.'));
                  } else {
                    final items =
                        snapshot.data!
                            .where(
                              (item) =>
                                  item.textDescriptionTitle
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  item.category.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  item.color.toLowerCase().contains(
                                    _searchQuery,
                                  ),
                            )
                            .toList();
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(
                          item: item,
                          onDelete: () async {
                            await _wardrobeService.deleteWardrobeItem(item.id);
                            setState(() {
                              _fetchWardrobeItems();
                            });
                          },
                          onToggleFavorite: () async {
                            await _wardrobeService.toggleFavorite(
                              item.id,
                              item.isFavorite,
                            );
                            setState(() {
                              _fetchWardrobeItems();
                            });
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
