import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final bool isLoading;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: CircleAvatar(
            radius: 60,
            backgroundImage:
                imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : const AssetImage('web/assets/icons/default_avatar.png')
                        as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
