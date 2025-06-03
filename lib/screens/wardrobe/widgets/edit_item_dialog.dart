import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/wardrobe_item.dart';
import '../../../services/wardrobe_service.dart';
import '../../../constants/wardrobe_constants.dart';

class EditItemDialog extends StatefulWidget {
  final WardrobeItem item;
  final VoidCallback onSave;

  const EditItemDialog({super.key, required this.item, required this.onSave});

  @override
  EditItemDialogState createState() => EditItemDialogState();
}

class EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _titleController;
  late String _selectedCategory;
  late String _selectedColor;
  late String _selectedSize;
  late String _selectedBrand;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.item.textDescriptionTitle,
    );
    _selectedCategory = widget.item.category;
    _selectedColor = widget.item.color;
    _selectedSize = widget.item.size;
    _selectedBrand = widget.item.brand;
    _imageUrl = widget.item.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isUploading = true;
    });
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
            'wardrobe_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          await storageRef.putData(bytes, metadata);
          final url = await storageRef.getDownloadURL();
          setState(() {
            _imageUrl = url;
          });
        }
      }
    } catch (e) {
      // Optionally show error
    }
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Wardrobe Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bildvisning och byt-bild-knapp
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    _imageUrl != null && _imageUrl!.isNotEmpty
                        ? Image.network(
                          _imageUrl!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'web/assets/icons/default_item_image.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Byt bild'),
              ),
            ],
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
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
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedColor,
              items:
                  wardrobeColors
                      .map(
                        (color) =>
                            DropdownMenuItem(value: color, child: Text(color)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedColor = value!),
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedSize,
              items:
                  wardrobeSizes
                      .map(
                        (size) =>
                            DropdownMenuItem(value: size, child: Text(size)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedSize = value!),
              decoration: const InputDecoration(labelText: 'Size'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              items:
                  wardrobeBrands
                      .map(
                        (brand) =>
                            DropdownMenuItem(value: brand, child: Text(brand)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedBrand = value!),
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isUploading
                  ? null
                  : () async {
                    final dialogContext = context; // Spara undan context
                    final updatedItem = widget.item.copyWith(
                      textDescriptionTitle: _titleController.text,
                      category: _selectedCategory,
                      color: _selectedColor,
                      size: _selectedSize,
                      brand: _selectedBrand,
                      imageUrl: _imageUrl,
                    );
                    await WardrobeService().updateWardrobeItem(updatedItem);
                    widget.onSave();
                    if (mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
