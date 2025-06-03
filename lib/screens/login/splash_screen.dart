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

  bool _showCurtains = true;

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

    _curtainController.forward();
    _fadeController.forward();

    _curtainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showCurtains = false;
        });
      }
    });

    // Vänta alltid minst 2.5 sekunder innan redirect
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      // Låt routerns redirect-logik avgöra vart vi ska
      final user = authStateListener.currentUser;
      if (user != null) {
        context.go('/home');
      } else {
        context.go('/');
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
          // LoginScreen fade in bakom
          FadeTransition(opacity: _fadeAnimation, child: const LoginScreen()),

          // Blockera interaktion medan animation pågår
          if (_showCurtains)
            const IgnorePointer(ignoring: true, child: SizedBox.expand()),

          // Draperi-animation ovanpå
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

          // Laddningsindikator i mitten
          if (_showCurtains)
            const Center(
              child: CircularProgressIndicator(color: Colors.black54),
            ),
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
