import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  String _selectedCategory = wardrobeCategories.first;
  String _selectedColor = wardrobeColors.first;
  final _imageUrlController = TextEditingController();
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
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('wardrobe_images')
            .child('${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putData(_webImageBytes!);
        return await storageRef.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image: $e');
        rethrow;
      }
    } else {
      if (_selectedImage == null) return null;
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('wardrobe_images')
            .child('${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
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
      // ignore: undefined_class
      final picker = ImagePicker();
      // ignore: undefined_identifier
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
    if (!context.mounted) return; // Change from !mounted
    showDialog(
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
                              value!.isEmpty ? 'Please enter a title' : null,
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
                        if (context.mounted) {
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
                        if (context.mounted) {
                          setState(() {
                            _selectedColor = value!;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Color'),
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
                onPressed: () {
                  _addWardrobeItem();
                  Navigator.pop(context);
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
      );

      try {
        await _wardrobeService.addWardrobeItem(newItem);
        if (!mounted) return; // Kontrollera om State är monterad
        setState(() {
          _titleController.clear();
          _imageUrlController.clear();
          _selectedImage = null;
          _webImageBytes = null;
          _fetchWardrobeItems();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
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
          isDesktop
              ? null
              : AppBar(
                title: const DynamicMobileAppBarTitle(),
                // Ta bort actions: här, DynamicMobileAppBarTitle har redan logout/toggle
              ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) const DynamicDesktopTitle(),
            const SizedBox(height: 32),
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
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(
                          item: item,
                          onDelete: () async {
                            try {
                              await _wardrobeService.deleteWardrobeItem(
                                item.id,
                              );
                              if (context.mounted) {
                                // Guard with context.mounted
                                _fetchWardrobeItems();
                                setState(() {});
                              }
                            } catch (e) {
                              if (context.mounted) {
                                // Guard with context.mounted
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting item: $e'),
                                  ),
                                );
                              }
                            }
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
