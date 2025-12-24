import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../models/bubble_type.dart';
import '../bubble_game.dart';
import 'bubble.dart';

class Shooter extends PositionComponent with HasGameReference<BubbleGame> {
  Bubble? currentBubble;
  Bubble? nextBubble;
  List<BubbleType> availableTypes = [];

  final Function(Bubble) onBubbleShot;

  bool canShoot = true;

  Shooter({required this.onBubbleShot});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(100, 100);
    anchor = Anchor.center;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, GameConfig.shooterY);
  }

  void loadNextBubble(List<BubbleType> types) {
    availableTypes = types;

    // Move next bubble to current
    if (nextBubble != null) {
      currentBubble = Bubble(
        type: nextBubble!.type,
        state: BubbleState.idle,
        position: position.clone(),
      );
    } else {
      currentBubble = Bubble(
        type: BubbleTypeExtension.randomFrom(availableTypes),
        state: BubbleState.idle,
        position: position.clone(),
      );
    }

    // Generate new next bubble
    nextBubble = Bubble(
      type: BubbleTypeExtension.randomFrom(availableTypes),
      state: BubbleState.idle,
      position: position + Vector2(60, 50),
    );

    canShoot = true;
  }

  void shoot(double angle) {
    if (!canShoot || currentBubble == null) return;

    canShoot = false;

    final bubble = Bubble(
      type: currentBubble!.type,
      state: BubbleState.idle,
      position: position.clone(),
    );
    bubble.shoot(angle);

    onBubbleShot(bubble);
    currentBubble = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw shooter base
    final basePaint = Paint()
      ..color = const Color(0xFF34495E)
      ..style = PaintingStyle.fill;

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 80, height: 30),
      const Radius.circular(15),
    );
    canvas.drawRRect(baseRect, basePaint);

    // Draw current bubble
    if (currentBubble != null) {
      _drawBubble(canvas, Offset.zero, currentBubble!.type, GameConfig.bubbleRadius);
    }

    // Draw next bubble (smaller)
    if (nextBubble != null) {
      _drawBubble(
        canvas,
        const Offset(60, 40),
        nextBubble!.type,
        GameConfig.bubbleRadius * 0.6,
      );

      // Draw "NEXT" label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'NEXT',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(48, 60));
    }
  }

  void _drawBubble(Canvas canvas, Offset center, BubbleType type, double radius) {
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [
        type.color.withAlpha((255 * 0.9).round()),
        type.color,
        type.darkColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.4).round());
    canvas.drawCircle(
      center + Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.25,
      highlightPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = type.darkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, borderPaint);
  }
}
