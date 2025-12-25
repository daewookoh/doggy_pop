import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../models/bubble_type.dart';
import '../../utils/hex_grid_utils.dart';
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
    // Position at horizontal center, vertical position from HexGridUtils (dynamically calculated)
    position = Vector2(size.x / 2, HexGridUtils.shooterY);
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

    // Draw current bubble with paw print
    if (currentBubble != null) {
      _drawBubbleWithPaw(canvas, Offset.zero, currentBubble!.type, GameConfig.bubbleRadius);
    }

    // Draw next bubble on the right side (same Y level)
    if (nextBubble != null) {
      // Calculate position: right side of game area
      final nextBubbleX = game.size.x / 2 - position.x + game.size.x - 50;
      _drawBubbleWithPaw(
        canvas,
        Offset(nextBubbleX, 0),
        nextBubble!.type,
        GameConfig.bubbleRadius * 0.7,
      );

      // Draw "NEXT" label above the next bubble
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'NEXT',
          style: TextStyle(
            color: Color(0xFF7A9BB8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(nextBubbleX - 14, -35));
    }
  }

  void _drawBubbleWithPaw(Canvas canvas, Offset center, BubbleType type, double radius) {
    // Draw bubble with soft pastel gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        Colors.white.withAlpha((255 * 0.9).round()),
        type.color.withAlpha((255 * 0.85).round()),
        type.color,
        type.darkColor.withAlpha((255 * 0.9).round()),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);

    // Draw paw print
    _drawPawPrint(canvas, center, type, radius);

    // Draw bubble shine highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.6).round());
    canvas.drawCircle(
      center + Offset(-radius * 0.35, -radius * 0.35),
      radius * 0.2,
      highlightPaint,
    );

    // Small secondary highlight
    final smallHighlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.4).round());
    canvas.drawCircle(
      center + Offset(-radius * 0.15, -radius * 0.5),
      radius * 0.1,
      smallHighlightPaint,
    );

    // Soft border
    final borderPaint = Paint()
      ..color = type.darkColor.withAlpha((255 * 0.5).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, borderPaint);
  }

  void _drawPawPrint(Canvas canvas, Offset center, BubbleType type, double radius) {
    final pawMainColor = type.pawColor;
    final pawShadowColor = type.pawDarkColor;

    final mainPadPaint = Paint()..color = pawMainColor;
    final mainPadShadowPaint = Paint()..color = pawShadowColor;

    // Draw main pad shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.15),
        width: radius * 0.7,
        height: radius * 0.55,
      ),
      mainPadShadowPaint,
    );

    // Draw main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.12),
        width: radius * 0.65,
        height: radius * 0.5,
      ),
      mainPadPaint,
    );

    // Main pad highlight
    final padHighlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.4).round());
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-radius * 0.08, radius * 0.02),
        width: radius * 0.25,
        height: radius * 0.18,
      ),
      padHighlightPaint,
    );

    // Toe pads
    final toePadPaint = Paint()..color = pawMainColor;
    final toeShadowPaint = Paint()..color = pawShadowColor;

    final toeOffsets = [
      Offset(-radius * 0.32, -radius * 0.25),
      Offset(-radius * 0.12, -radius * 0.38),
      Offset(radius * 0.12, -radius * 0.38),
      Offset(radius * 0.32, -radius * 0.25),
    ];

    final toeSizes = [radius * 0.18, radius * 0.19, radius * 0.19, radius * 0.18];

    // Draw toe shadows
    for (int i = 0; i < toeOffsets.length; i++) {
      canvas.drawCircle(
        center + toeOffsets[i] + Offset(0, radius * 0.02),
        toeSizes[i],
        toeShadowPaint,
      );
    }

    // Draw toe pads
    for (int i = 0; i < toeOffsets.length; i++) {
      canvas.drawCircle(
        center + toeOffsets[i],
        toeSizes[i] * 0.9,
        toePadPaint,
      );

      // Toe highlight
      canvas.drawCircle(
        center + toeOffsets[i] + Offset(-toeSizes[i] * 0.2, -toeSizes[i] * 0.2),
        toeSizes[i] * 0.3,
        padHighlightPaint,
      );
    }
  }
}
