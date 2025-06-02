import 'package:flutter/material.dart';
import 'package:outfitly/screens/wardrobe/cloths/cloths_item_screen.dart';
import '../screens/calendar/calendar_planner_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/wardrobe/outfits/outfits_screen.dart';
import '../screens/wardrobe/wardrobe_screen.dart';
import '../screens/user/user_screen.dart';

class AppRoute {
  final String title;
  final IconData icon;
  final String route;
  final Widget page;

  AppRoute({
    required this.title,
    required this.icon,
    required this.route,
    required this.page,
  });
}

final List<AppRoute> appRoutes = [
  AppRoute(
    title: 'Home',
    icon: Icons.home,
    route: '/home',
    page: const HomeScreen(),
  ),
  AppRoute(
    title: 'Wardrobe',
    icon: Icons.door_sliding,
    route: '/wardrobe',
    page: const WardrobeScreen(),
  ),
  AppRoute(
    title: 'Items',
    icon: Icons.checkroom,
    route: '/wardrobe/items',
    page: const ClothsItemScreen(),
  ),
  AppRoute(
    title: 'Outfits',
    icon: Icons.style,
    route: '/wardrobe/outfits',
    page: const OutfitsScreen(),
  ),
  AppRoute(
    title: 'Outfits Calendar',
    icon: Icons.edit_calendar,
    route: '/calendar',
    page: const CalenderPlannerScreen(),
  ),
  AppRoute(
    title: 'User',
    icon: Icons.person,
    route: '/user',
    page: const UserScreen(),
  ),
];
