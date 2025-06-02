import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

class DynamicMobileAppBarTitle extends StatelessWidget {
  const DynamicMobileAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final AppRoute route = appRoutes.firstWhere(
      (r) => currentRoute == r.route,
      orElse: () => appRoutes.first,
    );
    final themeProvider = ThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Ikon + titel till vänster
        Icon(
          route.icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          route.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Spacer för att trycka ut knapparna till höger
        const Spacer(),
        // Toggle och logga ut till höger
        IconButton(
          icon: const Icon(Icons.brightness_6),
          tooltip: isDark ? 'Light mode' : 'Dark mode',
          onPressed: () {
            themeProvider.toggleTheme(!isDark);
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            await AuthService().signOut();
            if (context.mounted) {
              context.go('/');
            }
          },
        ),
      ],
    );
  }
}
