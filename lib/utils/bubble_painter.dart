import 'package:flutter/material.dart';
import '../models/bubble_type.dart';

/// Shared bubble painting utilities
class BubblePainter {
  // Cached paints for performance
  static final Paint _highlightPaint = Paint()
    ..color = Colors.white.withAlpha(153); // 0.6 * 255
  static final Paint _smallHighlightPaint = Paint()
    ..color = Colors.white.withAlpha(102); // 0.4 * 255
  static final Paint _padHighlightPaint = Paint()
    ..color = Colors.white.withAlpha(102); // 0.4 * 255

  /// Draw a complete bubble with paw print
  static void drawBubble(
    Canvas canvas,
    Offset center,
    BubbleType type,
    double radius,
  ) {
    // Draw bubble gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        Colors.white.withAlpha(230), // 0.9 * 255
        type.color.withAlpha(217), // 0.85 * 255
        type.color,
        type.darkColor.withAlpha(230), // 0.9 * 255
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);

    // Draw paw print
    drawPawPrint(canvas, center, type, radius);

    // Draw highlights
    canvas.drawCircle(
      center + Offset(-radius * 0.35, -radius * 0.35),
      radius * 0.2,
      _highlightPaint,
    );

    canvas.drawCircle(
      center + Offset(-radius * 0.15, -radius * 0.5),
      radius * 0.1,
      _smallHighlightPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = type.darkColor.withAlpha(128) // 0.5 * 255
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, borderPaint);
  }

  /// Draw paw print at specified position
  static void drawPawPrint(
    Canvas canvas,
    Offset center,
    BubbleType type,
    double radius,
  ) {
    final pawPaint = Paint()..color = type.pawColor;
    final shadowPaint = Paint()..color = type.pawDarkColor;

    // Main pad shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.15),
        width: radius * 0.7,
        height: radius * 0.55,
      ),
      shadowPaint,
    );

    // Main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.12),
        width: radius * 0.65,
        height: radius * 0.5,
      ),
      pawPaint,
    );

    // Main pad highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-radius * 0.08, radius * 0.02),
        width: radius * 0.25,
        height: radius * 0.18,
      ),
      _padHighlightPaint,
    );

    // Toe positions and sizes
    const toeData = [
      (-0.32, -0.25, 0.18), // Left outer
      (-0.12, -0.38, 0.19), // Left inner
      (0.12, -0.38, 0.19), // Right inner
      (0.32, -0.25, 0.18), // Right outer
    ];

    // Draw toe shadows, then pads, then highlights
    for (final (dx, dy, sizeRatio) in toeData) {
      final toeCenter = center + Offset(radius * dx, radius * dy);
      final toeSize = radius * sizeRatio;

      // Shadow
      canvas.drawCircle(
        toeCenter + Offset(0, radius * 0.02),
        toeSize,
        shadowPaint,
      );
    }

    for (final (dx, dy, sizeRatio) in toeData) {
      final toeCenter = center + Offset(radius * dx, radius * dy);
      final toeSize = radius * sizeRatio;

      // Pad
      canvas.drawCircle(toeCenter, toeSize * 0.9, pawPaint);

      // Highlight
      canvas.drawCircle(
        toeCenter + Offset(-toeSize * 0.2, -toeSize * 0.2),
        toeSize * 0.3,
        _padHighlightPaint,
      );
    }
  }
}
