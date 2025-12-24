import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ComboEffect extends Component {
  final Vector2 position;
  final int comboCount;
  final int score;

  double _elapsed = 0;
  double _scale = 0;
  double _opacity = 1;
  double _offsetY = 0;

  static const double duration = 1.0;

  ComboEffect({
    required this.position,
    required this.comboCount,
    required this.score,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    final progress = _elapsed / duration;

    // Scale animation
    if (progress < 0.2) {
      _scale = _easeOutBack(progress / 0.2);
    } else {
      _scale = 1.0;
    }

    // Move up
    _offsetY = progress * 50;

    // Fade out in last 30%
    if (progress > 0.7) {
      _opacity = 1 - ((progress - 0.7) / 0.3);
    }
  }

  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.x, position.y - _offsetY);
    canvas.scale(_scale);

    // Draw combo text
    if (comboCount >= 4) {
      _drawText(
        canvas,
        comboCount >= 5 ? 'AMAZING!' : 'GREAT!',
        const Offset(0, -30),
        comboCount >= 5 ? const Color(0xFFE74C3C) : const Color(0xFFF1C40F),
        24,
      );
    }

    // Draw score
    _drawText(
      canvas,
      '+$score',
      Offset.zero,
      Colors.white,
      20,
    );

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withAlpha((_opacity * 255).round()),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha((_opacity * 150).round()),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2),
    );
  }
}

class ScorePopup extends Component {
  final Vector2 position;
  final int score;

  double _elapsed = 0;
  double _opacity = 1;
  double _offsetY = 0;

  static const double duration = 0.8;

  ScorePopup({
    required this.position,
    required this.score,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    final progress = _elapsed / duration;
    _offsetY = progress * 40;
    _opacity = 1 - progress;
  }

  @override
  void render(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '+$score',
        style: TextStyle(
          color: Colors.white.withAlpha((_opacity * 255).round()),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.x - textPainter.width / 2, position.y - _offsetY),
    );
  }
}
