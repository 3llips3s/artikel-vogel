import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class GapSparkle extends PositionComponent {
  double lifetime = 0;
  final double maxLifetime = 0.6;
  late List<SparkleParticle> particles;
  final Random random = Random();

  GapSparkle({required Vector2 gapCenter}) {
    position = gapCenter;

    // 12 particles in a burst pattern
    particles = List.generate(12, (i) {
      final angle = (i / 12) * 2 * pi;
      return SparkleParticle(
        angle: angle,
        speed: 80 + random.nextDouble() * 40,
        startDelay: random.nextDouble() * 0.1,
      );
    });
  }

  @override
  void update(double dt) {
    lifetime += dt;

    if (lifetime >= maxLifetime) {
      removeFromParent();
      return;
    }

    for (var particle in particles) {
      particle.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = lifetime / maxLifetime;

    for (var particle in particles) {
      if (particle.active) {
        final opacity = (1 - progress).clamp(0.0, 1.0);
        final paint =
            Paint()
              ..color = Color.lerp(
                Colors.yellowAccent,
                Colors.orangeAccent,
                progress,
              )!.withOpacity(opacity)
              ..style = PaintingStyle.fill;

        final size = 4 * (1 - progress * 0.5);
        canvas.drawCircle(Offset(particle.x, particle.y), size, paint);

        // glow effect
        final glowPaint =
            Paint()
              ..color = AppColors.white.withOpacity(opacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(particle.x, particle.y), size + 2, glowPaint);
      }
    }
  }
}

class SparkleParticle {
  double x = 0;
  double y = 0;
  final double angle;
  final double speed;
  final double startDelay;
  double age = 0;
  bool active = false;

  SparkleParticle({
    required this.angle,
    required this.speed,
    required this.startDelay,
  });

  void update(double dt) {
    age += dt;

    if (age >= startDelay) {
      active = true;
      x += cos(angle) * speed * dt;
      y += sin(angle) * speed * dt;
    }
  }
}
