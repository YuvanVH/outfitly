import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:outfitly/services/auth_service.dart';
import 'wardrobe_sub_button.dart';
import 'smooth_notched_shape.dart';

class MobileBottomNav extends StatefulWidget {
  final Widget child;
  const MobileBottomNav({super.key, required this.child});

  @override
  State<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends State<MobileBottomNav>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _wardrobeExpanded = false;
  int? _selectedWardrobeIndex;

  final List<String> _mainRoutes = ['/home', '/wardrobe', '/calendar', '/user'];

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _onMainTap(int index) {
    if (index == 1) {
      if (!_wardrobeExpanded) {
        setState(() {
          _currentIndex = 1;
          _wardrobeExpanded = true;
          _controller.forward();
        });
        context.go(_mainRoutes[1]);
      } else {
        setState(() {
          _wardrobeExpanded = false;
          _controller.reverse();
          _currentIndex = 1;
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
        _wardrobeExpanded = false;
        _controller.reverse();
        _selectedWardrobeIndex = null;
      });
      context.go(_mainRoutes[index]);
    }
  }

  void _handleLogout() async {
    await AuthService().signOut();
    if (!mounted) return;
    context.go('/splash?logout=true');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMainButton(IconData icon, int index, String label) {
    final theme = Theme.of(context);
    final bool isSelected = _currentIndex == index && !_wardrobeExpanded;
    final bool isWardrobeSelected =
        _wardrobeExpanded && _selectedWardrobeIndex == null && index == 1;

    final Color bgColor =
        (isSelected || isWardrobeSelected)
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;
    final Color iconColor =
        (isSelected || isWardrobeSelected)
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () => _onMainTap(index),
      onLongPress:
          index == 3 ? _handleLogout : null, // Logout on long-press User
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow:
                  (isSelected || isWardrobeSelected)
                      ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(48),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                      ]
                      : [],
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  (isSelected || isWardrobeSelected)
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodySmall?.color ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  double get notchCenterX {
    final width = MediaQuery.of(context).size.width;
    return (width / 4) * (_currentIndex + 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final double wardrobeCenterX = (width / 4) * 1.45;

    return Stack(
      children: [
        widget.child,
        if (_wardrobeExpanded)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                debugPrint('Tapped outside submenu');
                safeSetState(() {
                  _wardrobeExpanded = false;
                  _controller.reverse();
                });
              },
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            elevation: 12,
            shape: ShapeBorderWithNotch(notchCenterX),
            color: theme.bottomAppBarTheme.color ?? theme.colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMainButton(Icons.home, 0, 'Home'),
                    _buildMainButton(Icons.door_sliding, 1, 'Wardrobe'),
                    _buildMainButton(Icons.edit_calendar, 2, 'Planner'),
                    _buildMainButton(Icons.person, 3, 'User'),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_wardrobeExpanded)
          Positioned(
            bottom: 90,
            left: (wardrobeCenterX - 58),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WardrobeSubButton(
                        icon: Icons.checkroom,
                        label: 'My Clothes',
                        index: 0,
                        route: '/wardrobe/items',
                        selected: _selectedWardrobeIndex == 0,
                        onPressed: () {
                          safeSetState(() {
                            _selectedWardrobeIndex = 0;
                            _wardrobeExpanded = false;
                            _controller.reverse();
                            _currentIndex = 1;
                          });
                          context.go('/wardrobe/items');
                        },
                      ),
                      const SizedBox(width: 24),
                      WardrobeSubButton(
                        icon: Icons.style,
                        label: 'My Outfits',
                        index: 1,
                        route: '/wardrobe/outfits',
                        selected: _selectedWardrobeIndex == 1,
                        onPressed: () {
                          safeSetState(() {
                            _selectedWardrobeIndex = 1;
                            _wardrobeExpanded = false;
                            _controller.reverse();
                            _currentIndex = 1;
                          });
                          context.go('/wardrobe/outfits');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
