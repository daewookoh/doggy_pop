import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../bubble_game.dart';

class Ceiling extends PositionComponent with HasGameReference<BubbleGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(0, 0);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, GameConfig.gridOffsetY);
  }

  @override
  void render(Canvas canvas) {
    // Draw ceiling background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2C3E50),
          const Color(0xFF1a1a2e),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Draw bottom border
    final borderPaint = Paint()
      ..color = const Color(0xFF4A5568)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.y - 1),
      Offset(size.x, size.y - 1),
      borderPaint,
    );

    // Draw decorative pattern
    final patternPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.1).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.x; x += 40) {
      canvas.drawLine(
        Offset(x, size.y - 10),
        Offset(x + 20, size.y - 20),
        patternPaint,
      );
      canvas.drawLine(
        Offset(x + 20, size.y - 20),
        Offset(x + 40, size.y - 10),
        patternPaint,
      );
    }
  }
}
