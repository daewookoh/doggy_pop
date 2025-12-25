import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../config/game_config.dart';
import '../../models/bubble_type.dart';
import '../../utils/bubble_painter.dart';
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
    BubblePainter.drawBubble(canvas, Offset.zero, type, radius);
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
