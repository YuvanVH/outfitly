import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:outfitly/services/auth_service.dart';
import '../../main.dart';
import '../../router/routes.dart';

class DesktopSidebar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const DesktopSidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  int? _hoveredIndex;

  void _handleLogout() async {
    await AuthService().signOut();
    if (!mounted) return;
    context.go('/splash?logout=true');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final currentRoute = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      width: widget.isExpanded ? 240 : 80,
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(46),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildSidebarHeader(),
          Expanded(
            child: ListView(
              children: [
                ...appRoutes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final route = entry.value;
                  return _SidebarItem(
                    icon: route.icon,
                    label: route.title,
                    isExpanded: widget.isExpanded,
                    isHovered: _hoveredIndex == index,
                    isSelected: currentRoute == route.route,
                    onTap: () => context.go(route.route),
                    onHoverChange: (hovered) {
                      setState(() {
                        _hoveredIndex = hovered ? index : null;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _ThemeToggleButton(),
          ),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            isExpanded: widget.isExpanded,
            isHovered: _hoveredIndex == appRoutes.length,
            isSelected: false,
            onTap: _handleLogout,
            onHoverChange: (hovered) {
              setState(() {
                _hoveredIndex = hovered ? appRoutes.length : null;
              });
            },
          ),
          _buildToggleButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Image.asset(
          'web/assets/icons/hanger-purple.png',
          height: widget.isExpanded ? 50 : 35,
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return InkWell(
      onTap: widget.onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Icon(
          widget.isExpanded
              ? Icons.keyboard_double_arrow_left
              : Icons.keyboard_double_arrow_right,
          size: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final bool isHovered;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChange;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.isHovered,
    required this.isSelected,
    required this.onTap,
    required this.onHoverChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final outline = theme.colorScheme.outline;
    final onSurface = theme.colorScheme.onSurface;

    final bool active = isSelected;
    final Color circleColor = active ? primary : outline;
    final Color iconColor = active ? onPrimary : onSurface;
    final Color textColor = active ? primary : onSurface;

    final bgColor =
        isSelected
            ? primary.withAlpha(48)
            : isHovered
            ? primary.withAlpha(40)
            : Colors.transparent;

    final item = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          isExpanded
              ? Row(
                children: [
                  _buildIconCircle(icon, iconColor, circleColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
              : Center(child: _buildIconCircle(icon, iconColor, circleColor)),
    );

    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: Tooltip(
        message: isExpanded ? '' : label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: item,
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpanded =
        context
            .findAncestorStateOfType<_DesktopSidebarState>()
            ?.widget
            .isExpanded ??
        true;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    final Color iconColor = isDark ? Colors.white : Colors.grey[800]!;
    final iconBgColor = primary.withAlpha(13);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child:
          isExpanded
              ? InkWell(
                onTap: () => themeProvider.toggleTheme(!isDark),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconBgColor,
                        ),
                        child: Icon(
                          Icons.brightness_6,
                          size: 20,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isDark ? 'Light mode' : 'Dark mode',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Tooltip(
                message: isDark ? 'Light mode' : 'Dark mode',
                child: InkWell(
                  onTap: () => themeProvider.toggleTheme(!isDark),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBgColor,
                    ),
                    child: Icon(Icons.brightness_6, size: 20, color: iconColor),
                  ),
                ),
              ),
    );
  }
}
