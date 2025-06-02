import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';

class DynamicDesktopTitle extends StatelessWidget {
  const DynamicDesktopTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final AppRoute route = appRoutes.firstWhere(
      (r) => currentRoute == r.route,
      orElse: () => appRoutes.first,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          route.icon,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          route.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
