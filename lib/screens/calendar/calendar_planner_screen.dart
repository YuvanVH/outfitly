import 'package:flutter/material.dart';
import '../../widgets/nav_bars/dynamic_desktop_title.dart';
import '../../widgets/nav_bars/dynamic_mobile_appbar_title.dart';

class CalenderPlannerScreen extends StatelessWidget {
  const CalenderPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const DynamicMobileAppBarTitle()),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) const DynamicDesktopTitle(),
            const SizedBox(height: 32),
            const Center(child: Text('Outfit Calendar Planner Screen')),
          ],
        ),
      ),
    );
  }
}
