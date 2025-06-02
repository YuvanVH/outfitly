import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWave extends AnimatedWidget {
  const AnimatedWave({super.key, required AnimationController controller})
    : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return CustomPaint(
      painter: WavePainter(animation.value),
      isComplex: true,
      child: const SizedBox.expand(),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  Path _buildWavePath(
    double width,
    double height,
    double yOffset,
    double amplitude,
    double frequency,
    double phase,
  ) {
    final path = Path();
    path.moveTo(0, yOffset);
    for (double x = 0; x <= width; x++) {
      final y = yOffset + sin(x * frequency + phase) * amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double phase = animationValue * 2 * pi;
    final double width = size.width;
    final double height = size.height;

    final wave1Paint =
        Paint()
          ..color = const Color(0xFF7206BF).withAlpha(80)
          ..style = PaintingStyle.fill;
    final wave2Paint =
        Paint()
          ..color = const Color(0xFF9A59FF).withAlpha(35)
          ..style = PaintingStyle.fill;
    final wave3Paint =
        Paint()
          ..color = const Color(0xFF4C65D4).withAlpha(50)
          ..style = PaintingStyle.fill;

    canvas.drawPath(
      _buildWavePath(width, height, height * 0.90, 20, 0.02, phase),
      wave1Paint,
    );
    canvas.drawPath(
      _buildWavePath(width, height, height * 0.86, 18, 0.018, phase + pi / 2),
      wave2Paint,
    );
    canvas.drawPath(
      _buildWavePath(width, height, height * 0.82, 14, 0.015, phase + pi),
      wave3Paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
