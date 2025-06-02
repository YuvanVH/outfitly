import 'package:flutter/material.dart';
// En NotchedShape som skapar en mjuk, kurvad notch (urgröpning) i en form.

/// Används t.ex. för att skapa en urgröpning i en BottomAppBar för en FloatingActionButton.
class SmoothNotchedShape extends NotchedShape {
  final double notchCenter; // X-koordinaten för notchens mittpunkt

  const SmoothNotchedShape(this.notchCenter);

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    // notchRadius: Radien på urgröpningen
    // s1: Avståndet från notchens kant till där kurvan börjar/avslutas
    // b: Y-koordinaten för toppen av formen
    const double notchRadius = 60; // Större radie för bredare notch
    final double s1 = 60;
    final double b = host.top;
    final double notchDepth = 40; // Mindre djup för rundare form

    // Skapar en Path som ritar formen med en mjuk notch i mitten
    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(notchCenter - notchRadius - s1, host.top)
      // Första kurvan (vänster sida av notch)
      ..cubicTo(
        notchCenter - notchRadius - 10, // Kontrollpunkt längre ut
        b,
        notchCenter - notchRadius + 20, // Kontrollpunkt närmare mitten
        b + notchDepth,
        notchCenter,
        b + notchDepth,
      )
      // Andra kurvan (höger sida av notch)
      ..cubicTo(
        notchCenter + notchRadius - 20, // Kontrollpunkt närmare mitten
        b + notchDepth,
        notchCenter + notchRadius + 10, // Kontrollpunkt längre ut
        b,
        notchCenter + notchRadius + s1,
        host.top,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

/// En ShapeBorder som använder SmoothNotchedShape för att skapa en border med notch.
/// Kan användas direkt som shape på t.ex. en Container eller BottomAppBar.
class ShapeBorderWithNotch extends ShapeBorder {
  final double notchX; // X-koordinaten för notchens mittpunkt
  const ShapeBorderWithNotch(this.notchX);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // Returnerar ytterkonturen med notch
    return SmoothNotchedShape(notchX).getOuterPath(rect, null);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // Returnerar en rektangel som inner path (kan anpassas vid behov)
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // Ingen extra målning behövs, formen används för clipping/border
  }
}
