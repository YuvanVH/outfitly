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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _showCurtains = false;
  final bool _showLoadingSplash = true;

  @override
  void initState() {
    super.initState();

    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _curtainAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _curtainController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);

    // Starta animationerna direkt när Flutter är igång
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _curtainController.forward();
      _fadeController.forward();
    });

    // När draperiet är klart, tillåt interaktion och gör redirect efter 1s
    _curtainController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showCurtains = false;
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          final uri = GoRouterState.of(context).uri;
          final isLogout = uri.queryParameters['logout'] == 'true';
          final user = authStateListener.currentUser;
          if (isLogout) {
            context.go('/');
          } else if (user != null) {
            context.go('/home');
          } else {
            context.go('/');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _curtainController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Laddningssplash (logotyp + spinner)
          if (_showLoadingSplash)
            Container(
              color: const Color(0xFF7206BF),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'web/assets/icons/hanger-load-animation.gif',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),

          // 2. LoginScreen fade in bakom draperiet
          if (!_showLoadingSplash)
            FadeTransition(opacity: _fadeAnimation, child: const LoginScreen()),

          // 3. Draperi-animation ovanpå
          if (_showCurtains)
            AnimatedBuilder(
              animation: _curtainAnimation,
              builder: (context, child) {
                final offset = screenWidth / 2 * _curtainAnimation.value;
                return Stack(
                  children: [
                    Positioned(
                      left: -offset,
                      child: CustomPaint(
                        painter: CurtainPainter(),
                        child: SizedBox(
                          width: screenWidth / 2,
                          height: screenHeight,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -offset,
                      child: CustomPaint(
                        painter: CurtainPainter(),
                        child: SizedBox(
                          width: screenWidth / 2,
                          height: screenHeight,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          // 4. Blockera interaktion under splash/draperi
          if (_showLoadingSplash || _showCurtains)
            const IgnorePointer(ignoring: true, child: SizedBox.expand()),
        ],
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

    // Stång
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 10), rodPaint);

    // Öglor
    for (int i = 0; i < 5; i++) {
      double x = (i + 1) * size.width / 6;
      canvas.drawCircle(Offset(x, 5), 5, loopPaint);
      canvas.drawLine(Offset(x, 5), Offset(x, 15), loopPaint);
    }

    // Draperi
    final path = Path();
    path.moveTo(0, 15);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, 15 + sin(i * 0.1) * 5); // Veck-effekt
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
