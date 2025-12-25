import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../utils/hex_grid_utils.dart';
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
    // Include SafeArea padding in ceiling height
    this.size = Vector2(size.x, HexGridUtils.safeAreaTop + GameConfig.gridOffsetY);
  }

  @override
  void render(Canvas canvas) {
    // Draw ceiling background - pastel gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFB5E5FF), // Light sky blue
          const Color(0xFFE8F4FC), // Soft white blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Draw bottom border - soft pastel
    final borderPaint = Paint()
      ..color = const Color(0xFF7AC5F5).withAlpha((255 * 0.5).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.y - 1),
      Offset(size.x, size.y - 1),
      borderPaint,
    );

    // Draw decorative pattern - soft dots
    final patternPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.5).round())
      ..style = PaintingStyle.fill;

    for (var x = 20.0; x < size.x; x += 40) {
      canvas.drawCircle(
        Offset(x, size.y - 8),
        3,
        patternPaint,
      );
    }
  }
}
