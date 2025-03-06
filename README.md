# Easy Confetti

A highly customizable Flutter confetti animation library with various particle shapes, animations, and color themes.

## Features

- Multiple confetti types: success, failed, celebration, achievement, levelUp
- Various particle shapes: circle, star, emoji, ribbons, paper, and more
- Different animation styles: fountain, explosion, fireworks, rain, falling, tornado
- Customizable color themes: rainbow, pastel, neon, gold, silver, festive, birthday, and model-based colors
- Supports dynamic color models for consistent theming
- Easily extensible for adding new particle shapes

## Usage

```dart
import 'package:easy_conffeti/easy_conffeti.dart';

// Show a confetti dialog
await ConfettiHelper.showConfettiDialog(
  context: context,
  confettiType: ConfettiType.celebration,
  confettiStyle: ConfettiStyle.star,
  animationStyle: AnimationConfetti.fireworks,
  colorTheme: ConfettiColorTheme.rainbow,
  message: "Congratulations! 🎉",
  durationInSeconds: 3,
);
```

## Adding Custom Particle Shapes

You can easily extend the library with your own particle shapes by creating a new class that extends `ParticleShapeRenderer`:

```dart
class HeartShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, size * 0.3);
    
    // Left curve
    path.cubicTo(
      -size * 0.6, -size * 0.3, 
      -size * 1.2, size * 0.6, 
      0, size
    );
    
    // Right curve
    path.cubicTo(
      size * 1.2, size * 0.6, 
      size * 0.6, -size * 0.3, 
      0, size * 0.3
    );
    
    canvas.drawPath(path, paint);
  }
}
```

## Animation Types

Choose from multiple animation patterns:

- `AnimationConfetti.fountain`: Particles shoot upward and fall back down
- `AnimationConfetti.explosion`: Particles expand outward from center
- `AnimationConfetti.fireworks`: Burst pattern with varied speeds
- `AnimationConfetti.rain`: Particles fall from top of screen
- `AnimationConfetti.falling`: Similar to rain but with more random horizontal movement
- `AnimationConfetti.tornado`: Swirling pattern around a central point

## Color Themes

The library comes with various pre-defined color themes:

- Basic themes: rainbow, pastel, neon, gold, silver
- Special themes: festive, birthday
- Model-based themes: orange, teal, blue, purple, pink, magenta, red, yellow, lime, lightGreen, green, gray

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  easy_conffeti: ^0.1.0
```

## License

MIT