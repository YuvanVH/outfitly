import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _curtainController;
  late Animation<double> _curtainAnimation;

  bool _showCurtains = true;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen initialized');

    _showCurtains = true;
    _hasRedirected = false;

    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _curtainAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _curtainController, curve: Curves.easeInOut),
    );

    // Start curtain animation after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _curtainController.forward();
      }
    });

    _curtainController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showCurtains = false;
        });
        debugPrint('SplashScreen: Curtains completed');
      }
    });

    // Force splash for 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted || _hasRedirected) return;

      _hasRedirected = true;

      final user = authStateListener.currentUser;
      final isLogout =
          GoRouterState.of(context).uri.queryParameters['logout'] == 'true';

      debugPrint(
        'SplashScreen redirect: isLogout=$isLogout, loggedIn=${user != null}',
      );

      if (isLogout || user == null) {
        GoRouter.of(context).go('/');
      } else {
        GoRouter.of(context).go('/home');
      }
    });
  }

  @override
  void dispose() {
    _curtainController.dispose();
    resetSplashState();
    super.dispose();
    debugPrint('SplashScreen disposed');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_hasRedirected) {
      debugPrint('SplashScreen build: Skipped due to redirect');
      return const Scaffold(body: SizedBox.shrink());
    }

    debugPrint(
      'SplashScreen build: Rendering with LoginScreen, theme=${Theme.of(context).scaffoldBackgroundColor}',
    );
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        canvasColor: const Color(0xFFFFFFFF),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(surface: const Color(0xFFFFFFFF)),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF), // Force pure white
        body: Stack(
          children: [
            // Background screen (hardcoded to match 23/5/2024 design)
            const LoginScreen(),

            // Block interaction during animation
            if (_showCurtains) const IgnorePointer(child: SizedBox.expand()),

            // Curtain animation
            if (_showCurtains)
              AnimatedBuilder(
                animation: _curtainAnimation,
                builder: (context, child) {
                  final offset = screenWidth * _curtainAnimation.value;
                  return Stack(
                    children: [
                      Positioned(
                        left: -offset,
                        child: Opacity(
                          opacity: 1.0, // Opaque curtains
                          child: CustomPaint(
                            painter: CurtainPainter(),
                            child: SizedBox(
                              width: screenWidth / 2,
                              height: screenHeight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -offset,
                        child: Opacity(
                          opacity: 1.0, // Opaque curtains
                          child: CustomPaint(
                            painter: CurtainPainter(),
                            child: SizedBox(
                              width: screenWidth / 2,
                              height: screenHeight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            // Loading indicator
            if (_showCurtains)
              const Center(
                child: CircularProgressIndicator(color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}

class CurtainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fabricColor = const Color.fromARGB(189, 53, 7, 102);
    final rodColor = Colors.grey.shade700;
    final loopColor = Colors.grey.shade500;

    final paint =
        Paint()
          ..color = fabricColor
          ..style = PaintingStyle.fill;

    final rodPaint =
        Paint()
          ..color = rodColor
          ..style = PaintingStyle.fill;

    final loopPaint =
        Paint()
          ..color = loopColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Rod
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 10), rodPaint);

    // Loops
    for (int i = 0; i < 5; i++) {
      double x = (i + 1) * size.width / 6;
      canvas.drawCircle(Offset(x, 5), 5, loopPaint);
      canvas.drawLine(Offset(x, 5), Offset(x, 15), loopPaint);
    }

    // Curtain fabric
    final path = Path();
    path.moveTo(0, 15);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, 15 + sin(i * 0.1) * 5); // Fold effect
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
