import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../config/game_config.dart';
import '../../utils/hex_grid_utils.dart';
import '../bubble_game.dart';

class AimLine extends Component with HasGameReference<BubbleGame> {
  Vector2? _startPosition;
  Vector2? _targetPosition;
  bool _isAiming = false;

  static const double _dotRadius = 4.0;
  static const double _dotSpacing = 20.0;
  static const int _maxDots = 30;

  @override
  void render(Canvas canvas) {
    if (!_isAiming || _startPosition == null || _targetPosition == null) {
      return;
    }

    final angle = getAngle();
    if (angle == null) return;

    // Don't draw if aiming too low
    if (angle > -0.1 || angle < -pi + 0.1) return;

    _drawAimLine(canvas, angle);
  }

  void _drawAimLine(Canvas canvas, double angle) {
    // Use actual shooter position (center of screen X, dynamically calculated shooterY)
    final shooterPos = Vector2(game.size.x / 2, HexGridUtils.shooterY);
    final direction = Vector2(cos(angle), sin(angle));

    var currentPos = shooterPos.clone();
    var currentDirection = direction.clone();

    final dotPaint = Paint()
      ..color = const Color(0xFF7AC5F5)
      ..style = PaintingStyle.fill;

    // Ceiling Y with SafeArea padding
    final ceilingY = HexGridUtils.safeAreaTop + GameConfig.gridOffsetY + GameConfig.bubbleRadius;

    for (var i = 0; i < _maxDots; i++) {
      // Move along the direction
      currentPos += currentDirection * _dotSpacing;

      // Check wall collision and reflect
      if (currentPos.x - GameConfig.bubbleRadius <= 0) {
        currentPos.x = GameConfig.bubbleRadius;
        currentDirection.x = -currentDirection.x;
      } else if (currentPos.x + GameConfig.bubbleRadius >= game.size.x) {
        currentPos.x = game.size.x - GameConfig.bubbleRadius;
        currentDirection.x = -currentDirection.x;
      }

      // Stop at ceiling
      if (currentPos.y <= ceilingY) {
        break;
      }

      // Draw dot with fading effect
      final alpha = 1.0 - (i / _maxDots) * 0.7;
      dotPaint.color = const Color(0xFF7AC5F5).withAlpha((255 * alpha).round());

      canvas.drawCircle(
        Offset(currentPos.x, currentPos.y),
        _dotRadius * (1.0 - i / _maxDots * 0.5),
        dotPaint,
      );
    }
  }

  void startAiming(Vector2 position) {
    _isAiming = true;
    _startPosition = Vector2(game.size.x / 2, HexGridUtils.shooterY);
    _targetPosition = position;
  }

  void updateAim(Vector2 position) {
    if (_isAiming) {
      _targetPosition = position;
    }
  }

  void stopAiming() {
    _isAiming = false;
    _startPosition = null;
    _targetPosition = null;
  }

  double? getAngle() {
    if (_startPosition == null || _targetPosition == null) return null;

    final shooterPos = Vector2(game.size.x / 2, HexGridUtils.shooterY);

    return atan2(
      _targetPosition!.y - shooterPos.y,
      _targetPosition!.x - shooterPos.x,
    );
  }
}
