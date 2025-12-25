import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../config/game_config.dart';
import '../../models/bubble_type.dart';
import '../../utils/hex_grid_utils.dart';
import '../bubble_game.dart';

enum BubbleState { idle, moving, attached, popping, dropping }

class Bubble extends CircleComponent with HasGameReference<BubbleGame>, CollisionCallbacks {
  final BubbleType type;
  BubbleState state;
  Vector2 velocity = Vector2.zero();

  int? gridRow;
  int? gridCol;

  Bubble({
    required this.type,
    this.state = BubbleState.idle,
    super.position,
  }) : super(
          radius: GameConfig.bubbleRadius,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add collision detection for moving and attached bubbles
    if (state == BubbleState.moving || state == BubbleState.attached) {
      add(CircleHitbox());
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw bubble with soft pastel gradient effect
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
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );

    canvas.drawCircle(Offset.zero, radius, paint);

    // Draw paw print
    _drawPawPrint(canvas);

    // Draw bubble shine highlight (top-left)
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.6).round())
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-radius * 0.35, -radius * 0.35),
      radius * 0.2,
      highlightPaint,
    );

    // Small secondary highlight
    final smallHighlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.4).round())
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-radius * 0.15, -radius * 0.5),
      radius * 0.1,
      smallHighlightPaint,
    );

    // Draw soft border
    final borderPaint = Paint()
      ..color = type.darkColor.withAlpha((255 * 0.5).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset.zero, radius - 1, borderPaint);
  }

  void _drawPawPrint(Canvas canvas) {
    final pawMainColor = type.pawColor;
    final pawShadowColor = type.pawDarkColor;

    // Main pad (big oval at bottom)
    final mainPadPaint = Paint()..color = pawMainColor;
    final mainPadShadowPaint = Paint()..color = pawShadowColor;

    // Draw main pad shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, radius * 0.15),
        width: radius * 0.7,
        height: radius * 0.55,
      ),
      mainPadShadowPaint,
    );

    // Draw main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, radius * 0.12),
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
        center: Offset(-radius * 0.08, radius * 0.02),
        width: radius * 0.25,
        height: radius * 0.18,
      ),
      padHighlightPaint,
    );

    // Toe pads (4 small circles at top)
    final toePadPaint = Paint()..color = pawMainColor;
    final toeShadowPaint = Paint()..color = pawShadowColor;

    // Toe positions and sizes
    final toePositions = [
      Offset(-radius * 0.32, -radius * 0.25), // Left outer
      Offset(-radius * 0.12, -radius * 0.38), // Left inner
      Offset(radius * 0.12, -radius * 0.38),  // Right inner
      Offset(radius * 0.32, -radius * 0.25),  // Right outer
    ];

    final toeSizes = [
      radius * 0.18, // Left outer
      radius * 0.19, // Left inner
      radius * 0.19, // Right inner
      radius * 0.18, // Right outer
    ];

    // Draw toe shadows first
    for (int i = 0; i < toePositions.length; i++) {
      canvas.drawCircle(
        toePositions[i] + Offset(0, radius * 0.02),
        toeSizes[i],
        toeShadowPaint,
      );
    }

    // Draw toe pads
    for (int i = 0; i < toePositions.length; i++) {
      canvas.drawCircle(
        toePositions[i],
        toeSizes[i] * 0.9,
        toePadPaint,
      );

      // Toe highlight
      canvas.drawCircle(
        toePositions[i] + Offset(-toeSizes[i] * 0.2, -toeSizes[i] * 0.2),
        toeSizes[i] * 0.3,
        padHighlightPaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == BubbleState.moving) {
      _updateMoving(dt);
    } else if (state == BubbleState.dropping) {
      _updateDropping(dt);
    }
  }

  void _updateMoving(double dt) {
    position += velocity * dt;

    // Wall collision
    final gameWidth = game.size.x;
    if (position.x - radius <= 0) {
      position.x = radius;
      velocity.x = -velocity.x;
    } else if (position.x + radius >= gameWidth) {
      position.x = gameWidth - radius;
      velocity.x = -velocity.x;
    }

    // Ceiling collision (with SafeArea padding)
    final ceilingY = HexGridUtils.safeAreaTop + GameConfig.gridOffsetY;
    if (position.y - radius <= ceilingY) {
      position.y = ceilingY + radius;
      _attachToGrid();
    }
  }

  void _updateDropping(double dt) {
    velocity.y += GameConfig.gravity * dt;
    position += velocity * dt;

    // Remove when off screen
    if (position.y > game.size.y + radius * 2) {
      removeFromParent();
    }
  }

  void shoot(double angle) {
    state = BubbleState.moving;
    velocity = Vector2(
      cos(angle) * GameConfig.bubbleSpeed,
      sin(angle) * GameConfig.bubbleSpeed,
    );
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (state == BubbleState.moving && other is Bubble && other.state == BubbleState.attached) {
      _attachToGrid();
    }
  }

  void _attachToGrid() {
    if (state != BubbleState.moving) return;

    state = BubbleState.attached;
    velocity = Vector2.zero();

    // Find nearest grid position
    final gridPosition = game.bubbleGrid.getNearestGridPosition(position);
    gridRow = gridPosition.$1;
    gridCol = gridPosition.$2;

    // Snap to grid
    position = game.bubbleGrid.getWorldPosition(gridRow!, gridCol!);

    // Remove from game and add to grid
    removeFromParent();
    game.onBubbleAttached(this, gridRow!, gridCol!);
  }

  void pop() {
    state = BubbleState.popping;

    // Pop animation
    add(
      ScaleEffect.to(
        Vector2.all(1.3),
        EffectController(duration: 0.1),
        onComplete: () {
          add(
            ScaleEffect.to(
              Vector2.zero(),
              EffectController(duration: 0.1),
              onComplete: () => removeFromParent(),
            ),
          );
        },
      ),
    );

    add(
      OpacityEffect.to(
        0,
        EffectController(duration: 0.2),
      ),
    );
  }

  void drop() {
    state = BubbleState.dropping;
    velocity = Vector2(
      (Random().nextDouble() - 0.5) * 100,
      0,
    );

    // Remove collision
    children.whereType<CircleHitbox>().forEach((hitbox) {
      hitbox.removeFromParent();
    });
  }

  Bubble copyWith({Vector2? position, BubbleState? state}) {
    return Bubble(
      type: type,
      position: position ?? this.position.clone(),
      state: state ?? this.state,
    );
  }
}
