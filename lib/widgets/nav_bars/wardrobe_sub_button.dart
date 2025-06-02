import 'package:flutter/material.dart';

class WardrobeSubButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final String route;
  final bool selected;
  final void Function() onPressed;

  const WardrobeSubButton({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.route,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<WardrobeSubButton> createState() => _WardrobeSubButtonState();
}

class _WardrobeSubButtonState extends State<WardrobeSubButton> {
  bool isTapped = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isActive = isTapped || widget.selected || isHovered;

    final Color subBgColor =
        isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant.withAlpha(
              (isDark ? 0.5 : 0.93) * 255 ~/ 1,
            );

    final Color subIconColor =
        isActive
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt());

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => isTapped = true);
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) setState(() => isTapped = false);
              });
              widget.onPressed();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subBgColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: isTapped ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(widget.icon, color: subIconColor),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              color:
                  isActive
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodySmall?.color ??
                          const Color.fromARGB(255, 188, 188, 188),
            ),
          ),
        ],
      ),
    );
  }
}
