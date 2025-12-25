import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../models/bubble_type.dart';
import '../../utils/bubble_painter.dart';
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

  // Cached text painter for "NEXT" label
  static final TextPainter _nextLabelPainter = TextPainter(
    text: const TextSpan(
      text: 'NEXT',
      style: TextStyle(
        color: Color(0xFF7A9BB8),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // With anchor = center and size = (100, 100), local center is at (50, 50)
    final localCenter = Offset(size.x / 2, size.y / 2);

    // Draw current bubble with paw print at local center
    if (currentBubble != null) {
      BubblePainter.drawBubble(canvas, localCenter, currentBubble!.type, GameConfig.bubbleRadius);
    }

    // Draw next bubble on the right side (same Y level)
    if (nextBubble != null) {
      final nextBubbleX = localCenter.dx + (game.size.x / 2 - 50);
      BubblePainter.drawBubble(
        canvas,
        Offset(nextBubbleX, localCenter.dy),
        nextBubble!.type,
        GameConfig.bubbleRadius * 0.7,
      );

      // Draw "NEXT" label
      _nextLabelPainter.paint(canvas, Offset(nextBubbleX - 14, localCenter.dy - 35));
    }
  }
}
