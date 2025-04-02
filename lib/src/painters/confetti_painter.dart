import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../enums/confetti_enums.dart';

/// Confetti particle base class
class ConfettiParticle {
  Offset position; // normalized
  Offset velocity;
  Color color;
  double size;
  double rotationSpeed;
  String? emoji;
  double opacity; // 0..1
  double lifespan; // 0..1

  // Reference to the shape renderer (strategy pattern)
  final ParticleShapeRenderer shapeRenderer;

  ConfettiParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotationSpeed,
    this.emoji,
    required this.opacity,
    required this.lifespan,
    required this.shapeRenderer,
  });

  /// Factory method to create particles based on style
  static ConfettiParticle create({
    required Offset position,
    required Offset velocity,
    required Color color,
    required double size,
    required double rotationSpeed,
    required double opacity,
    required double lifespan,
    required ConfettiStyle style,
    String? emoji,
  }) {
    // Select the appropriate shape renderer based on style
    ParticleShapeRenderer shapeRenderer;

    switch (style) {
      case ConfettiStyle.custom:
        shapeRenderer = CircleShapeRenderer();
        break;
      case ConfettiStyle.star:
        shapeRenderer = StarShapeRenderer(points: 5);
        break;
      case ConfettiStyle.emoji:
        shapeRenderer = EmojiShapeRenderer(emoji: emoji ?? '🎉');
        break;
      case ConfettiStyle.ribbons:
        shapeRenderer = RibbonShapeRenderer();
        break;
      case ConfettiStyle.paper:
        shapeRenderer = PaperShapeRenderer();
        break;
    }

    return ConfettiParticle(
      position: position,
      velocity: velocity,
      color: color,
      size: size,
      rotationSpeed: rotationSpeed,
      emoji: emoji,
      opacity: opacity,
      lifespan: lifespan,
      shapeRenderer: shapeRenderer,
    );
  }

  /// Update particle position, rotation, etc.
  void update() {
    // Update position
    final dx = velocity.dx * 0.01;
    final dy = velocity.dy * 0.01;
    position = Offset(
      position.dx + dx,
      position.dy + dy,
    );

    // Update rotation
    rotationSpeed += 0.01;
  }

  /// Render the particle
  void render(Canvas canvas, Size size, Paint paint) {
    final px = position.dx * size.width;
    final py = position.dy * size.height;

    // Transform canvas
    canvas.save();
    canvas.translate(px, py);

    final angle = rotationSpeed * math.pi / 180.0;
    canvas.rotate(angle);

    // Apply opacity
    paint.color = color.withOpacity(opacity);

    // Use the strategy to render the shape
    shapeRenderer.render(canvas, paint, this.size);

    canvas.restore();
  }
}

/// Abstract base class for particle shape renderers (Strategy pattern)
abstract class ParticleShapeRenderer {
  void render(Canvas canvas, Paint paint, double size);
}

/// Circle shape renderer
class CircleShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    canvas.drawCircle(Offset.zero, size, paint);
  }
}

/// Star shape renderer
class StarShapeRenderer extends ParticleShapeRenderer {
  final int points;

  StarShapeRenderer({this.points = 5});

  @override
  void render(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final angle = math.pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2) == 0 ? size : size / 2;
      final x = r * math.sin(i * angle);
      final y = -r * math.cos(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Emoji renderer
class EmojiShapeRenderer extends ParticleShapeRenderer {
  final String emoji;

  EmojiShapeRenderer({required this.emoji});

  @override
  void render(Canvas canvas, Paint paint, double size) {
    final textSpan = TextSpan(
      text: emoji,
      style: TextStyle(fontSize: size * 2),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}

/// Ribbon shape renderer
class RibbonShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size * 0.5,
      height: size * 6,
    );
    canvas.drawRect(rect, paint);
  }
}

/// Paper shape renderer
class PaperShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size,
      height: size,
    );
    canvas.drawRect(rect, paint);
  }
}

/// Heart shape renderer (example of a new shape)
class HeartShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, size * 0.3);

    // Left curve
    path.cubicTo(-size * 0.6, -size * 0.3, -size * 1.2, size * 0.6, 0, size);

    // Right curve
    path.cubicTo(size * 1.2, size * 0.6, size * 0.6, -size * 0.3, 0, size * 0.3);

    canvas.drawPath(path, paint);
  }
}

/// Diamond shape renderer (example of another new shape)
class DiamondShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size); // Top
    path.lineTo(size, 0); // Right
    path.lineTo(0, size); // Bottom
    path.lineTo(-size, 0); // Left
    path.close();

    canvas.drawPath(path, paint);
  }
}

/// Triangle shape renderer (example of another new shape)
class TriangleShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size, size);
    path.lineTo(-size, size);
    path.close();

    canvas.drawPath(path, paint);
  }
}

/// Confetti painter class
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;
  final double physicsValue;
  final ConfettiType confettiType;
  final ConfettiStyle confettiStyle;
  final AnimationConfetti animationStyle;
  final BlendMode? blendMode;

  ConfettiPainter({
    required this.particles,
    required this.animationValue,
    required this.physicsValue,
    required this.confettiType,
    required this.confettiStyle,
    required this.animationStyle,
    this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    if (blendMode != null) {
      paint.blendMode = blendMode!;
    }

    for (var particle in particles) {
      // Update the particle
      particle.update();

      // Render the particle
      particle.render(canvas, size, paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

// Factory for generating particles (moved from ConfettiDialog)
class ParticleFactory {
  static List<ConfettiParticle> generateParticles({
    required ConfettiType confettiType,
    required ConfettiStyle confettiStyle,
    required AnimationConfetti animationStyle,
    required ConfettiColorTheme colorTheme,
    required ConfettiDensity density,
    required bool isColorMixedFromModel,
  }) {
    final rand = math.Random();
    final List<ConfettiParticle> particles = [];

    int quantity;
    switch (density) {
      case ConfettiDensity.low:
        quantity = 50;
        break;
      case ConfettiDensity.medium:
        quantity = 100;
        break;
      case ConfettiDensity.high:
        quantity = 200;
        break;
    }

    // Extra for celebration/levelUp
    if (confettiType == ConfettiType.celebration || confettiType == ConfettiType.levelUp) {
      quantity = (quantity * 1.5).round();
    }

    for (int i = 0; i < quantity; i++) {
      // Calculate initial position based on animation style
      Offset position = _calculateInitialPosition(animationStyle, rand);

      // Calculate velocity based on animation style
      Offset velocity = _calculateInitialVelocity(animationStyle, rand);

      // Get color based on theme
      Color color = _getColorFromTheme(rand, colorTheme, confettiType, isColorMixedFromModel);

      // Calculate size
      double size = 5.0 + rand.nextDouble() * 5.0;
      if (confettiStyle == ConfettiStyle.star || confettiStyle == ConfettiStyle.emoji) {
        size *= 1.5;
      }

      // Calculate rotation speed
      double rotationSpeed = 0.0;
      if (confettiStyle == ConfettiStyle.star ||
          confettiStyle == ConfettiStyle.ribbons ||
          confettiStyle == ConfettiStyle.paper) {
        rotationSpeed = (rand.nextDouble() - 0.5) * 10.0;
      }

      // Get emoji if needed
      String? emoji;
      if (confettiStyle == ConfettiStyle.emoji) {
        emoji = _getRandomEmoji(confettiType, rand);
      }

      // Create particle using factory method
      particles.add(
        ConfettiParticle.create(
          position: position,
          velocity: velocity,
          color: color,
          size: size,
          rotationSpeed: rotationSpeed,
          emoji: emoji,
          opacity: 0.8 + rand.nextDouble() * 0.2,
          lifespan: 0.7 + rand.nextDouble() * 0.3,
          style: confettiStyle,
        ),
      );
    }

    return particles;
  }

  // Helper methods (moved from ConfettiDialog)
  static Offset _calculateInitialPosition(AnimationConfetti style, math.Random rand) {
    switch (style) {
      case AnimationConfetti.fountain:
      case AnimationConfetti.explosion:
      case AnimationConfetti.fireworks:
        return const Offset(0.5, 0.5);
      case AnimationConfetti.rain:
        return Offset(rand.nextDouble(), -0.1);
      case AnimationConfetti.falling:
        return Offset(rand.nextDouble(), -0.2);
      case AnimationConfetti.tornado:
        return Offset(rand.nextDouble(), 0.5);
    }
  }

  static Offset _calculateInitialVelocity(AnimationConfetti style, math.Random rand) {
    double speed = rand.nextDouble() * 2 + 0.5;

    switch (style) {
      case AnimationConfetti.explosion:
        double angle = rand.nextDouble() * 2 * math.pi;
        return Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        );
      case AnimationConfetti.fountain:
        return Offset(
          (rand.nextDouble() - 0.5) * 1.2,
          -1.5 - rand.nextDouble(),
        );
      case AnimationConfetti.rain:
      case AnimationConfetti.falling:
        return Offset(
          (rand.nextDouble() - 0.5) * 0.8,
          0.5 + rand.nextDouble() * 1.5,
        );
      case AnimationConfetti.fireworks:
        double angle = rand.nextDouble() * 2 * math.pi;
        double spd = rand.nextDouble() * 3 + 0.5;
        return Offset(
          math.cos(angle) * spd,
          math.sin(angle) * spd,
        );
      case AnimationConfetti.tornado:
        double angle = rand.nextDouble() * 2 * math.pi;
        double radius = 0.2 + rand.nextDouble() * 0.8;
        return Offset(
          math.cos(angle) * radius,
          math.sin(angle) * radius,
        );
    }
  }

  static Color _getColorFromTheme(
      math.Random rand, ConfettiColorTheme colorTheme, ConfettiType confettiType, bool isColorMixedFromModel) {
    // Implementation from original code...
    // This would be moved from the original _getColorFromTheme method
    return Colors.red; // Placeholder
  }

  static String _getRandomEmoji(ConfettiType type, math.Random rand) {
    // Implementation from original code...
    // This would be moved from the original _getRandomEmoji method
    return '🎉'; // Placeholder
  }
}
