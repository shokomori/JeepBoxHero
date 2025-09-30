import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ParticleEffect extends PositionComponent {
  final Color color;
  final int particleCount;
  final double lifetime;

  final List<_Particle> particles = [];
  double elapsed = 0;

  ParticleEffect({
    required Vector2 position,
    required this.color,
    this.particleCount = 20,
    this.lifetime = 2.0,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final random = Random();
    for (var i = 0; i < particleCount; i++) {
      particles.add(
        _Particle(
          position: Vector2.zero(),
          velocity: Vector2(
            (random.nextDouble() - 0.5) * 200,
            (random.nextDouble() - 0.5) * 200,
          ),
          size: random.nextDouble() * 4 + 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    elapsed += dt;

    if (elapsed >= lifetime) {
      removeFromParent();
      return;
    }

    for (final particle in particles) {
      particle.position += particle.velocity * dt;
      particle.velocity.y += 100 * dt; // Gravity
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final alpha = (1 - (elapsed / lifetime)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      canvas.drawCircle(
        (position + particle.position).toOffset(),
        particle.size,
        paint,
      );
    }
  }
}

class _Particle {
  Vector2 position;
  Vector2 velocity;
  double size;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
  });
}
