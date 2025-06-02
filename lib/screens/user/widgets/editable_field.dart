import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEditToggle;

  const EditableField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              isEditing
                  ? TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                  )
                  : Text(
                    controller.text.isEmpty ? 'Not set' : controller.text,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: onEditToggle,
        ),
      ],
    );
  }
}
