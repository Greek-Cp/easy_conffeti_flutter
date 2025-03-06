# Awesome Confetti

A highly customizable Flutter confetti animation library with various particle shapes, animations, and color themes.

## Features

- Multiple confetti types: success, failed, celebration, achievement, levelUp
- Various particle shapes: circle, star, emoji, ribbons, paper, and more
- Different animation styles: fountain, explosion, fireworks, rain, falling, tornado
- Customizable color themes
- Easily extensible for adding new particle shapes

## Usage

```dart
import 'package:awesome_confetti/awesome_confetti.dart';

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