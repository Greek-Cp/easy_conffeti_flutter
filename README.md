![image](https://github.com/user-attachments/assets/87766c11-83c9-48ea-b84c-caad3b5bfd49)
## Easy Confetti

<p align="center">
  <a href="https://pub.dev/packages/easy_conffeti"><img src="https://img.shields.io/pub/v/easy_conffeti.svg" alt="Pub"></a>
  <a href="https://github.com/Greek-Cp/Easy-Confetti-Flutter"><img src="https://img.shields.io/github/stars/Greek-Cp/Easy-Confetti-Flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Stars"></a>
  <a href="https://github.com/Greek-Cp/Easy-Confetti-Flutter/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Greek-Cp/Easy-Confetti-Flutter" alt="License: MIT"></a>
</p>

A highly customizable Flutter confetti animation library with various particle shapes, animations, and color themes. Perfect for celebrations, achievements, and adding delight to your Flutter application.

## ✨ Features

- **Multiple confetti types**: success, failed, celebration, achievement, levelUp
- **Various particle shapes**: circle, star, emoji, ribbons, paper, and easily add your own
- **Different animation styles**: fountain, explosion, fireworks, rain, falling, tornado
- **Rich color themes**: rainbow, pastel, neon, gold, silver, festive, birthday, and model-based colors
- **Customizable density and duration**: control the amount and length of the confetti effect
- **Message support**: add custom messages to accompany your animations
- **Extensible architecture**: easily create your own particle shapes

## 📲 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  easy_conffeti: ^0.1.4
```

Or install via command line:
```
flutter pub add easy_conffeti
```

## 🚀 Quick Start

```dart
import 'package:easy_conffeti/easy_conffeti.dart';

// Show a simple celebration confetti dialog
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

## 📱 Usage Examples

### Celebration Effect

```dart
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

### Achievement Unlocked

```dart
await ConfettiHelper.showConfettiDialog(
  context: context,
  confettiType: ConfettiType.achievement,
  confettiStyle: ConfettiStyle.emoji,
  animationStyle: AnimationConfetti.fountain,
  colorTheme: ConfettiColorTheme.gold,
  message: "Achievement Unlocked! 🏆",
  durationInSeconds: 3,
);
```

### Level Up Animation

```dart
await ConfettiHelper.showConfettiDialog(
  context: context,
  confettiType: ConfettiType.levelUp,
  confettiStyle: ConfettiStyle.ribbons,
  animationStyle: AnimationConfetti.tornado,
  colorTheme: ConfettiColorTheme.blue,
  message: "Level Up! ⬆️",
  durationInSeconds: 3,
);
```

### Success Message

```dart
await ConfettiHelper.showConfettiDialog(
  context: context,
  confettiType: ConfettiType.success,
  confettiStyle: ConfettiStyle.paper,
  animationStyle: AnimationConfetti.explosion,
  colorTheme: ConfettiColorTheme.green,
  message: "Success! ✅",
  durationInSeconds: 3,
);
```

## 🎨 Customization

### Confetti Types
```dart
enum ConfettiType {
  success,
  failed,
  celebration,
  achievement,
  levelUp,
}
```

### Particle Styles
```dart
enum ConfettiStyle {
  custom,  // Simple circles
  star,    // Star shapes
  emoji,   // Emoji characters
  ribbons, // Ribbon strips
  paper,   // Paper squares
}
```

### Animation Styles
```dart
enum AnimationConfetti {
  fountain,  // Particles shoot upward and fall
  explosion, // Particles expand outward
  fireworks, // Burst pattern
  rain,      // Fall from top of screen
  falling,   // Similar to rain with horizontal movement
  tornado,   // Swirling pattern
}
```

### Color Themes
```dart
enum ConfettiColorTheme {
  rainbow,
  pastel,
  neon,
  gold,
  silver,
  festive,
  birthday,
  
  // Model-based themes
  orange,
  teal,
  blue,
  purple,
  pink,
  // ... and more
}
```

### Particle Density
```dart
enum ConfettiDensity {
  low,
  medium,
  high,
}
```

## 🧩 Adding Custom Particle Shapes

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

// Then use it in your confetti dialog
await ConfettiHelper.showConfettiDialog(
  context: context,
  confettiType: ConfettiType.celebration,
  confettiStyle: ConfettiStyle.custom, // Use custom style
  // ... other parameters
  // You'd need to add this to the ConfettiParticle.create factory method
);
```

## 📝 Live Designer Tool

Easy Confetti includes a live designer tool to help you experiment with different combinations:
![image](https://github.com/user-attachments/assets/2e8db40c-1018-4f6b-b2df-388526df9d55)

```dart
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Confetti Designer',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const ConfettiDesignerPage(),
    );
  }
}
```

The designer lets you:
- See immediate preview of your confetti effects
- Try different combinations of types, styles, and animations
- Copy the generated code directly for use in your app
- Experiment with color themes and density

## 📋 All Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `context` | BuildContext for showing the dialog | Required |
| `confettiType` | Type of confetti animation | Required |
| `confettiStyle` | Style of confetti particles | Required |
| `animationStyle` | Animation pattern for particles | Required |
| `colorTheme` | Color scheme for particles | `ConfettiColorTheme.rainbow` |
| `message` | Optional message to display | `null` |
| `useController` | Use external animation controller | `false` |
| `externalController` | External animation controller | `null` |
| `durationInSeconds` | Duration of the animation | `4` |
| `density` | Particle density | `ConfettiDensity.medium` |
| `blendMode` | Blend mode for particles | `null` |
| `onComplete` | Callback when animation completes | `null` |
| `isColorMixedFromModel` | Use mixed colors from model | `false` |

## 📱 Compatibility

- Flutter 3.0.0 or higher
- Dart 2.17.0 or higher
- Works on iOS, Android, Web, macOS, Windows and Linux

## 🤝 Contributing

Contributions are welcome! If you find any bugs or have feature requests, please open an issue on GitHub. If you'd like to contribute code, please fork the repository and submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`)
3. Commit your Changes (`git commit -m 'Add some amazing feature'`)
4. Push to the Branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📃 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgements

- Special thanks to Flutter and the amazing community
- Inspired by popular confetti libraries in various platforms

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Greek-Cp">Yanuar Tri Laksono</a>
</p>

# Easy Confetti Project Structure - Detailed Overview

## 1. PARTICLE SHAPES SYSTEM
- **Primary Files**: 
  - `lib/src/painters/confetti_particle.dart`
  - `lib/src/painters/particle_shape_renderer.dart`

- **Architecture**:
  - Based on Strategy Pattern with `ParticleShapeRenderer` as the abstract base class
  - Each shape is implemented as a separate class extending this base class
  - The `render(Canvas canvas, Paint paint, double size)` method must be overridden to implement drawing

- **Adding New Shapes**:
  - Create a new class extending `ParticleShapeRenderer`
  - Implement the `render()` method with your custom shape drawing logic using Flutter's Canvas API
  - Add your new shape to the factory method in `ConfettiParticle.create()`
  - Consider updating the `ConfettiStyle` enum if you want it selectable in the UI

- **Example Implementation**:
```dart
class DiamondShapeRenderer extends ParticleShapeRenderer {
  @override
  void render(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size);  // Top
    path.lineTo(size, 0);   // Right
    path.lineTo(0, size);   // Bottom
    path.lineTo(-size, 0);  // Left
    path.close();
    
    canvas.drawPath(path, paint);
  }
}
```

## 2. ANIMATION STYLES
- **Primary Files**:
  - `lib/src/enums/confetti_enums.dart` (AnimationConfetti enum)
  - `lib/src/widgets/confetti_dialog.dart` (_generateParticles method)
  - `lib/src/painters/confetti_particle.dart` (velocity handling)

- **Architecture**:
  - Each animation style has two key components:
    1. Initial position generation logic
    2. Velocity vector calculation

- **Adding New Animations**:
  1. Add a new value to the `AnimationConfetti` enum
  2. Implement position logic in the switch statement in `_generateParticles`
  3. Implement velocity calculation logic in the same method
  4. Consider physics interactions for special effects

- **Example Implementation**:
```dart
// In enums file
enum AnimationConfetti {
  fountain,
  explosion,
  fireworks,
  rain,
  falling,
  tornado,
  spiral, // New animation
}

// In _generateParticles method
switch (widget.animationStyle) {
  // ... existing cases
  case AnimationConfetti.spiral:
    position = const Offset(0.5, 0.5);
    double angle = i / quantity * 2 * math.pi;
    double distance = rand.nextDouble() * 0.5;
    velocity = Offset(
      math.cos(angle) * distance,
      math.sin(angle) * distance,
    );
    break;
}
```

## 3. COLOR THEMES
- **Primary Files**:
  - `lib/src/enums/confetti_enums.dart` (ConfettiColorTheme enum)
  - `lib/src/widgets/confetti_dialog.dart` (_getColorFromTheme method)
  - `lib/src/models/card_colors.dart` (for model-based colors)

- **Architecture**:
  - Basic themes use direct color generation logic
  - Model-based themes pull from CardColorModel instances
  - Color mixing is controlled by isColorMixedFromModel flag

- **Adding New Color Themes**:
  1. Add new value to the `ConfettiColorTheme` enum
  2. Implement color generation logic in the `_getColorFromTheme` method
  3. For model-based themes, define the CardColorModel in card_colors.dart

- **Example Implementation**:
```dart
// In enum file
enum ConfettiColorTheme {
  // ... existing values
  sunset, // New theme
}

// In _getColorFromTheme method
case ConfettiColorTheme.sunset:
  return HSVColor.fromAHSV(
    1.0,
    rand.nextDouble() * 60.0 + 10.0, // Orange to red hues
    0.8 + rand.nextDouble() * 0.2,
    0.9 + rand.nextDouble() * 0.1,
  ).toColor();
```

## 4. CONFETTI TYPES
- **Primary Files**:
  - `lib/src/enums/confetti_enums.dart` (ConfettiType enum)
  - `lib/src/widgets/confetti_dialog.dart` (_getMessageColor method)
  - `lib/src/helpers/confetti_helper.dart` (showConfettiDialog method)

- **Architecture**:
  - Types affect message color and can influence default values
  - Types can be used for semantic differentiation

- **Adding New Types**:
  1. Add new value to the `ConfettiType` enum
  2. Update the `_getMessageColor` method for appropriate text coloring
  3. Consider adding default emoji sets if using emoji style

- **Example Implementation**:
```dart
// In enum file
enum ConfettiType {
  // ... existing values
  milestone, // New type
}

// In _getMessageColor method
case ConfettiType.milestone:
  return Colors.indigo.shade700;

// In _getRandomEmoji method
case ConfettiType.milestone:
  List<String> milestoneEmojis = ['🏅', '💯', '📊', '📈', '🚀', '🥇'];
  return milestoneEmojis[rand.nextInt(milestoneEmojis.length)];
```

## 5. DESIGN TOOL
- **Primary Files**:
  - `lib/example/lib/main.dart`
  - `lib/example/lib/confetti_designer_page.dart`

- **Architecture**:
  - Live preview using a custom painter
  - UI controls for all confetti parameters
  - Code generation for easy copy-paste

- **Updating for New Features**:
  1. Add new options to the appropriate dropdown widgets
  2. Update the particle generation logic for the preview
  3. Make sure code snippet generation includes the new options

## 6. OTHER COMPONENTS
- **Density Control**: 
  - Defined in `lib/src/enums/confetti_enums.dart`
  - Implemented in `_generateParticles` method
  
- **Message Handling**:
  - Implemented in the ConfettiDialog widget UI layout
  - Styling based on confetti type in `_getMessageColor`

- **Blend Modes**:
  - Passed to Paint object in the ConfettiPainter class

When adding any new features, remember to:
1. Update README.md with the new functionality
2. Add entries to CHANGELOG.md
3. Update version number in pubspec.yaml
4. Consider adding example usage in example/main.dart
5. Make sure the live designer supports the new feature

This detailed structure should help AI understand how to navigate and extend the project when adding new features in the future.
