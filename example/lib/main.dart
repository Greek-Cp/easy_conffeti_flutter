import 'dart:math' as math;
import 'package:easy_conffeti/easy_conffeti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const ConfettiDesignerPage(),
    );
  }
}

class ConfettiDesignerPage extends StatefulWidget {
  const ConfettiDesignerPage({Key? key}) : super(key: key);

  @override
  State<ConfettiDesignerPage> createState() => _ConfettiDesignerPageState();
}

class _ConfettiDesignerPageState extends State<ConfettiDesignerPage>
    with TickerProviderStateMixin {
  // Default configuration values
  ConfettiType _confettiType = ConfettiType.celebration;
  ConfettiStyle _confettiStyle = ConfettiStyle.star;
  AnimationConfetti _animationStyle = AnimationConfetti.fireworks;
  ConfettiColorTheme _colorTheme = ConfettiColorTheme.rainbow;
  ConfettiDensity _density = ConfettiDensity.medium;
  bool _isColorMixedFromModel = false;
  int _durationInSeconds = 3;
  String _message = "Congratulations! 🎉";

  // Controllers for live preview
  late AnimationController _previewAnimController;
  late Animation<double> _previewAnim;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _previewAnim = CurvedAnimation(
      parent: _previewAnimController,
      curve: Curves.linear,
    );

    _previewAnimController.addListener(() {
      setState(() {
        // This will rebuild and update the preview
      });
    });

    _generateParticles();
    _previewAnimController.repeat();
  }

  @override
  void dispose() {
    _previewAnimController.dispose();
    super.dispose();
  }

  void _regeneratePreview() {
    _particles.clear();
    _generateParticles();
    setState(() {});
  }

  void _generateParticles() {
    final rand = math.Random();
    int quantity = 60; // Smaller count for preview

    for (int i = 0; i < quantity; i++) {
      // Position logic based on animation style
      Offset position;
      switch (_animationStyle) {
        case AnimationConfetti.fountain:
          position = const Offset(0.5, 0.8);
          break;
        case AnimationConfetti.explosion:
        case AnimationConfetti.fireworks:
          position = const Offset(0.5, 0.5);
          break;
        case AnimationConfetti.rain:
          position = Offset(rand.nextDouble(), -0.1);
          break;
        case AnimationConfetti.falling:
          position = Offset(rand.nextDouble(), -0.2);
          break;
        case AnimationConfetti.tornado:
          position = Offset(0.5, 0.7);
          break;
      }

      // Velocity logic
      double speed = rand.nextDouble() * 2 + 0.5;
      Offset velocity;
      switch (_animationStyle) {
        case AnimationConfetti.explosion:
          double angle = rand.nextDouble() * 2 * math.pi;
          velocity = Offset(
            math.cos(angle) * speed,
            math.sin(angle) * speed,
          );
          break;
        case AnimationConfetti.fountain:
          velocity = Offset(
            (rand.nextDouble() - 0.5) * 1.2,
            -1.5 - rand.nextDouble(),
          );
          break;
        case AnimationConfetti.rain:
        case AnimationConfetti.falling:
          velocity = Offset(
            (rand.nextDouble() - 0.5) * 0.8,
            0.5 + rand.nextDouble() * 1.5,
          );
          break;
        case AnimationConfetti.fireworks:
          double angle = rand.nextDouble() * 2 * math.pi;
          double spd = rand.nextDouble() * 3 + 0.5;
          velocity = Offset(
            math.cos(angle) * spd,
            math.sin(angle) * spd,
          );
          break;
        case AnimationConfetti.tornado:
          double angle = rand.nextDouble() * 2 * math.pi;
          double radius = 0.2 + rand.nextDouble() * 0.8;
          velocity = Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );
          break;
      }

      // Simplified color selection for preview
      Color color;
      switch (_colorTheme) {
        case ConfettiColorTheme.rainbow:
          color = HSVColor.fromAHSV(
            1.0,
            rand.nextDouble() * 360.0,
            0.8 + rand.nextDouble() * 0.2,
            0.8 + rand.nextDouble() * 0.2,
          ).toColor();
          break;
        case ConfettiColorTheme.pastel:
          color = HSVColor.fromAHSV(
            1.0,
            rand.nextDouble() * 360.0,
            0.4 + rand.nextDouble() * 0.3,
            0.9 + rand.nextDouble() * 0.1,
          ).toColor();
          break;
        case ConfettiColorTheme.blue:
          color = Colors.blue.shade300;
          break;
        case ConfettiColorTheme.red:
          color = Colors.red.shade300;
          break;
        case ConfettiColorTheme.green:
          color = Colors.green.shade300;
          break;
        case ConfettiColorTheme.gold:
          color = Colors.amber.shade300;
          break;
        default:
          color = Colors.purple.shade300;
      }

      double size = 4.0 + rand.nextDouble() * 4.0;
      if (_confettiStyle == ConfettiStyle.star ||
          _confettiStyle == ConfettiStyle.emoji) {
        size *= 1.5;
      }

      double rotationSpeed = 0.0;
      if (_confettiStyle == ConfettiStyle.star ||
          _confettiStyle == ConfettiStyle.ribbons ||
          _confettiStyle == ConfettiStyle.paper) {
        rotationSpeed = (rand.nextDouble() - 0.5) * 10.0;
      }

      String? emoji;
      if (_confettiStyle == ConfettiStyle.emoji) {
        // Simplified emoji selection for preview
        List<String> emojis = ['🎉', '🎊', '✨', '🏆', '⭐', '🌟', '💯'];
        emoji = emojis[rand.nextInt(emojis.length)];
      }

      // Create appropriate shape renderer
      ParticleShapeRenderer shapeRenderer;
      switch (_confettiStyle) {
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
        default:
          shapeRenderer = CircleShapeRenderer();
      }

      _particles.add(
        ConfettiParticle(
          position: position,
          velocity: velocity,
          color: color,
          size: size,
          rotationSpeed: rotationSpeed,
          emoji: emoji,
          opacity: 0.8 + rand.nextDouble() * 0.2,
          lifespan: 0.7 + rand.nextDouble() * 0.3,
          shapeRenderer: shapeRenderer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Confetti Live Designer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill),
            onPressed: _showFullConfetti,
            tooltip: 'Show Full Confetti Effect',
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Live preview area
        _buildPreviewArea(),

        // Controls in a scrollable area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                _buildQuickPresets(),
                _buildControlPanels(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Live preview area
        Expanded(
          flex: 1,
          child: _buildPreviewArea(),
        ),

        // Controls in a scrollable area
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                _buildQuickPresets(),
                _buildControlPanels(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      height: 280,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Confetti preview
          ConfettiPreview(
            particles: _particles,
            animationValue: _previewAnim.value,
          ),

          // Message preview
          if (_message.isNotEmpty)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getMessagePreviewColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Label in corner
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Live Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMessagePreviewColor() {
    switch (_confettiType) {
      case ConfettiType.success:
        return Colors.green.shade700;
      case ConfettiType.failed:
        return Colors.blue.shade700;
      case ConfettiType.celebration:
        return Colors.purple.shade700;
      case ConfettiType.achievement:
        return Colors.amber.shade800;
      case ConfettiType.levelUp:
        return Colors.deepOrange.shade700;
    }
  }

  Widget _buildQuickPresets() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 18),
                SizedBox(width: 8),
                Text(
                  'Quick Presets',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetButton(
                    'Celebration',
                    ConfettiType.celebration,
                    ConfettiStyle.star,
                    AnimationConfetti.fireworks,
                    ConfettiColorTheme.rainbow,
                    'Congratulations! 🎉',
                  ),
                  _buildPresetButton(
                    'Success',
                    ConfettiType.success,
                    ConfettiStyle.paper,
                    AnimationConfetti.explosion,
                    ConfettiColorTheme.green,
                    'Success! ✅',
                  ),
                  _buildPresetButton(
                    'Achievement',
                    ConfettiType.achievement,
                    ConfettiStyle.emoji,
                    AnimationConfetti.fountain,
                    ConfettiColorTheme.gold,
                    'Achievement Unlocked! 🏆',
                  ),
                  _buildPresetButton(
                    'Level Up',
                    ConfettiType.levelUp,
                    ConfettiStyle.star,
                    AnimationConfetti.tornado,
                    ConfettiColorTheme.blue,
                    'Level Up! ⬆️',
                  ),
                  _buildPresetButton(
                    'Try Again',
                    ConfettiType.failed,
                    ConfettiStyle.ribbons,
                    AnimationConfetti.rain,
                    ConfettiColorTheme.purple,
                    'Try Again! 💪',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(
    String label,
    ConfettiType type,
    ConfettiStyle style,
    AnimationConfetti animation,
    ConfettiColorTheme color,
    String message,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _confettiType = type;
            _confettiStyle = style;
            _animationStyle = animation;
            _colorTheme = color;
            _message = message;
          });
          _regeneratePreview();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildControlPanels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Two panels in a row for saving space
          Row(
            children: [
              Expanded(
                child: _buildControlPanel(
                  title: 'Type & Style',
                  controls: [
                    _buildSelector(
                      title: 'Confetti Type',
                      value: _confettiType,
                      items: ConfettiType.values,
                      onChanged: (value) {
                        setState(() {
                          _confettiType = value!;
                          // Update message based on type
                          switch (_confettiType) {
                            case ConfettiType.success:
                              _message = "Success! ✅";
                              break;
                            case ConfettiType.failed:
                              _message = "Try again! 💪";
                              break;
                            case ConfettiType.celebration:
                              _message = "Congratulations! 🎉";
                              break;
                            case ConfettiType.achievement:
                              _message = "Achievement Unlocked! 🏆";
                              break;
                            case ConfettiType.levelUp:
                              _message = "Level Up! ⬆️";
                              break;
                          }
                        });
                        _regeneratePreview();
                      },
                    ),
                    _buildSelector(
                      title: 'Particle Style',
                      value: _confettiStyle,
                      items: ConfettiStyle.values,
                      onChanged: (value) {
                        setState(() {
                          _confettiStyle = value!;
                        });
                        _regeneratePreview();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildControlPanel(
                  title: 'Animation & Colors',
                  controls: [
                    _buildSelector(
                      title: 'Animation Style',
                      value: _animationStyle,
                      items: AnimationConfetti.values,
                      onChanged: (value) {
                        setState(() {
                          _animationStyle = value!;
                        });
                        _regeneratePreview();
                      },
                    ),
                    _buildSelector(
                      title: 'Color Theme',
                      value: _colorTheme,
                      items: [
                        ConfettiColorTheme.rainbow,
                        ConfettiColorTheme.pastel,
                        ConfettiColorTheme.neon,
                        ConfettiColorTheme.gold,
                        ConfettiColorTheme.silver,
                        ConfettiColorTheme.festive,
                        ConfettiColorTheme.birthday,
                        ConfettiColorTheme.red,
                        ConfettiColorTheme.blue,
                        ConfettiColorTheme.green,
                        ConfettiColorTheme.purple,
                      ],
                      onChanged: (value) {
                        setState(() {
                          _colorTheme = value!;
                        });
                        _regeneratePreview();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Another row of panels
          Row(
            children: [
              Expanded(
                child: _buildControlPanel(
                  title: 'Particle Properties',
                  controls: [
                    _buildSelector(
                      title: 'Density',
                      value: _density,
                      items: ConfettiDensity.values,
                      onChanged: (value) {
                        setState(() {
                          _density = value!;
                        });
                      },
                    ),
                    _buildSlider(
                      title: 'Duration (seconds)',
                      value: _durationInSeconds.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          _durationInSeconds = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildControlPanel(
                  title: 'Message & Options',
                  controls: [
                    _buildTextInput(
                      title: 'Custom Message',
                      value: _message,
                      onChanged: (value) {
                        setState(() {
                          _message = value;
                        });
                      },
                    ),
                    _buildSwitch(
                      title: 'Mix Colors from Model',
                      value: _isColorMixedFromModel,
                      onChanged: (value) {
                        setState(() {
                          _isColorMixedFromModel = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Code snippet
          _buildCodeSnippet(),
        ],
      ),
    );
  }

  Widget _buildControlPanel({
    required String title,
    required List<Widget> controls,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(),
            ...controls,
          ],
        ),
      ),
    );
  }

  Widget _buildSelector<T>({
    required String title,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            value: value,
            isDense: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString().split('.').last,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                value.round().toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput({
    required String title,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSnippet() {
    final codeSnippet = '''
ConfettiHelper.showConfettiDialog(
  context: context,
  confettiType: ConfettiType.${_confettiType.toString().split('.').last},
  confettiStyle: ConfettiStyle.${_confettiStyle.toString().split('.').last},
  animationStyle: AnimationConfetti.${_animationStyle.toString().split('.').last},
  colorTheme: ConfettiColorTheme.${_colorTheme.toString().split('.').last},
  density: ConfettiDensity.${_density.toString().split('.').last},
  durationInSeconds: $_durationInSeconds,
  message: "$_message",
  isColorMixedFromModel: $_isColorMixedFromModel,
);''';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.code, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Generated Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: codeSnippet));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'Copy to clipboard',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                codeSnippet,
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullConfetti() async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: _confettiType,
      confettiStyle: _confettiStyle,
      animationStyle: _animationStyle,
      useController: false,
      durationInSeconds: _durationInSeconds,
      colorTheme: _colorTheme,
      density: _density,
      message: _message,
      isColorMixedFromModel: _isColorMixedFromModel,
    );
  }
}

class ConfettiPreview extends StatelessWidget {
  final List<ConfettiParticle> particles;
  final double animationValue;

  const ConfettiPreview({
    Key? key,
    required this.particles,
    required this.animationValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConfettiPreviewPainter(
        particles: particles,
        animationValue: animationValue,
      ),
      size: Size.infinite,
    );
  }
}

class ConfettiPreviewPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;

  ConfettiPreviewPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Update position based on velocity and animation
      final dx = particle.velocity.dx * 0.01;
      final dy = particle.velocity.dy * 0.01;

      // Wrap around logic for continuous animation
      particle.position = Offset(
        (particle.position.dx + dx) % 1.2,
        (particle.position.dy + dy) % 1.2,
      );

      // If particle moves off-screen, reset it
      if (particle.position.dx < -0.2 ||
          particle.position.dx > 1.2 ||
          particle.position.dy < -0.2 ||
          particle.position.dy > 1.2) {
        particle.position = Offset(
          0.5,
          particle.velocity.dy > 0 ? -0.1 : 1.1,
        );
      }

      // Update rotation
      particle.rotationSpeed += 0.01;

      final px = particle.position.dx * size.width;
      final py = particle.position.dy * size.height;

      // Transform canvas for rotation
      canvas.save();
      canvas.translate(px, py);

      final angle = particle.rotationSpeed * math.pi / 180.0;
      canvas.rotate(angle);

      // Apply color with opacity
      paint.color = particle.color.withOpacity(particle.opacity);

      // Render particle using its shape renderer
      particle.shapeRenderer.render(canvas, paint, particle.size);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPreviewPainter oldDelegate) => true;
}
