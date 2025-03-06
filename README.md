![image](https://github.com/user-attachments/assets/87766c11-83c9-48ea-b84c-caad3b5bfd49)
## Easy Confetti

<p align="center">
  ![image](https://github.com/user-attachments/assets/3edf9d1a-0111-4707-84a7-0a913cc1ac25)

</p>

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
  easy_conffeti: ^0.1.2
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
