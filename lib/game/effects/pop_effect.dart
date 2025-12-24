import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PopEffect extends Component {
  final Vector2 position;
  final Color color;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  double _elapsed = 0;
  static const double duration = 0.5;

  PopEffect({
    required this.position,
    required this.color,
    int particleCount = 12,
  }) {
    // Create particles
    for (var i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + _random.nextDouble() * 0.5;
      final speed = 100 + _random.nextDouble() * 150;
      _particles.add(_Particle(
        position: position.clone(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        radius: 3 + _random.nextDouble() * 4,
        color: color,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    final progress = _elapsed / duration;
    for (final particle in _particles) {
      particle.update(dt, progress);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      particle.render(canvas);
    }
  }
}

class _Particle {
  Vector2 position;
  Vector2 velocity;
  double radius;
  Color color;
  double _progress = 0;

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });

  void update(double dt, double progress) {
    _progress = progress;

    // Apply gravity
    velocity.y += 500 * dt;

    // Move
    position += velocity * dt;

    // Slow down
    velocity *= 0.98;
  }

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withAlpha((255 * (1 - _easeOut(_progress))).round().clamp(0, 255))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.x, position.y),
      radius * (1 - _easeOut(_progress) * 0.5),
      paint,
    );
  }

  double _easeOut(double t) => 1 - pow(1 - t, 3).toDouble();
}

class BurstEffect extends Component {
  final Vector2 position;
  final Color color;
  double _scale = 0;
  double _opacity = 1;
  double _elapsed = 0;
  static const double duration = 0.3;

  BurstEffect({
    required this.position,
    required this.color,
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
    _scale = _easeOut(progress) * 60;
    _opacity = 1 - progress;
  }

  double _easeOut(double t) => 1 - pow(1 - t, 3).toDouble();

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withAlpha((_opacity * 150).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * (1 - _elapsed / duration);

    canvas.drawCircle(
      Offset(position.x, position.y),
      _scale,
      paint,
    );
  }
}
