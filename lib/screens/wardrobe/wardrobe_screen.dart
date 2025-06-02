import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added for go_router support
import '../../services/wardrobe_service.dart';
import '../../models/wardrobe_item.dart';
import '../../constants/wardrobe_constants.dart';
import '../../widgets/item_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../widgets/nav_bars/dynamic_desktop_title.dart';
import '../../widgets/nav_bars/dynamic_mobile_appbar_title.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  WardrobeScreenState createState() => WardrobeScreenState();
}

class WardrobeScreenState extends State<WardrobeScreen> {
  final WardrobeService _wardrobeService = WardrobeService();
  late Future<List<WardrobeItem>> _wardrobeItems;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = wardrobeCategories.first;
  String _selectedColor = wardrobeColors.first;
  String _selectedSize = wardrobeSizes.first;
  String _selectedBrand = wardrobeBrands.first;
  File? _selectedImage;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchWardrobeItems();
  }

  void _fetchWardrobeItems() {
    _wardrobeItems = _wardrobeService.getWardrobeItems();
  }

  Future<String?> _uploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    if (kIsWeb) {
      if (_webImageBytes == null) return null;
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
          'wardrobe_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await storageRef.putData(_webImageBytes!);
        return await storageRef.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image: $e');
        rethrow;
      }
    } else {
      if (_selectedImage == null) return null;
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
          'wardrobe_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await storageRef.putFile(_selectedImage!);
        return await storageRef.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image: $e');
        rethrow;
      }
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = null;
          _webImageBytes = pickedFile;
        });
      }
    } else {
      await _pickImageForMobile();
    }
  }

  Future<void> _pickImageForMobile() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking image on mobile: $e');
    }
  }

  Future<void> _showAddItemDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Wardrobe Item'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter a title'
                                  : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items:
                          wardrobeCategories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedColor,
                      items:
                          wardrobeColors
                              .map(
                                (color) => DropdownMenuItem(
                                  value: color,
                                  child: Text(color),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedColor = value!;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedSize,
                      items:
                          wardrobeSizes
                              .map(
                                (size) => DropdownMenuItem(
                                  value: size,
                                  child: Text(size),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedSize = value!;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Size'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedBrand,
                      items:
                          wardrobeBrands
                              .map(
                                (brand) => DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedBrand = value!;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    if (_selectedImage != null && !kIsWeb)
                      Image.file(
                        _selectedImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    if (_webImageBytes != null && kIsWeb)
                      Image.memory(
                        _webImageBytes!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _addWardrobeItem();
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _addWardrobeItem() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to add items')),
          );
        }
        return;
      }
      String? imageUrl = await _uploadImage();
      final newItem = WardrobeItem(
        id: '',
        userId: userId,
        category: _selectedCategory,
        color: _selectedColor,
        textDescriptionTitle: _titleController.text,
        imageUrl: imageUrl ?? 'https://via.placeholder.com/150',
        createdAt: DateTime.now(),
        size: _selectedSize,
        isFavorite: false,
        brand: _selectedBrand,
      );

      try {
        await _wardrobeService.addWardrobeItem(newItem);
        if (!mounted) return;
        setState(() {
          _titleController.clear();
          _imageUrlController.clear();
          _selectedImage = null;
          _webImageBytes = null;
          _fetchWardrobeItems();
        });
        if (mounted) {
          // Added mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          // Added mounted check
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding item: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
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
            // Banner
            const Text(
              'What are you looking for?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Buttons for Items and Outfits
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      () => GoRouter.of(context).go('/wardrobe/items'), // Fixed
                  icon: const Icon(Icons.checkroom),
                  label: const Text('Items'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed:
                      () =>
                          GoRouter.of(context).go('/wardrobe/outfits'), // Fixed
                  icon: const Icon(Icons.style),
                  label: const Text('Outfits'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Favorites List (Horizontal)
            const Text(
              'Favorites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                    final items = snapshot.data!;
                    final favorites =
                        items.where((item) => item.isFavorite).toList();
                    final nonFavorites =
                        items.where((item) => !item.isFavorite).toList();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Horizontal Favorites List
                          if (favorites.isNotEmpty)
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: favorites.length,
                                itemBuilder: (context, index) {
                                  final item = favorites[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ItemCard(
                                      item: item,
                                      onDelete: () async {
                                        await _wardrobeService
                                            .deleteWardrobeItem(item.id);
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
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            const Text('No favorites yet.'),
                          const SizedBox(height: 16),
                          // All Items List (Vertical)
                          const Text(
                            'All Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: nonFavorites.length,
                            itemBuilder: (context, index) {
                              final item = nonFavorites[index];
                              return ItemCard(
                                item: item,
                                onDelete: () async {
                                  await _wardrobeService.deleteWardrobeItem(
                                    item.id,
                                  );
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
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
