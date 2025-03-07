import 'package:easy_conffeti/easy_conffeti.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

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
  cardDialog: QuizCompletionCard(
        message: "Congratulation You Already Complete The Quiz",
        score: "40",
      ),
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
      cardDialog: QuizCompletionCard(
        message: "Congratulation You Already Complete The Quiz",
        score: "40",
      ),
      message: _message,
      isColorMixedFromModel: _isColorMixedFromModel,
    );
  }
}

class QuizFailedCard extends StatefulWidget {
  final String score;
  final String message;

  const QuizFailedCard({
    Key? key,
    required this.score,
    required this.message,
  }) : super(key: key);

  @override
  State<QuizFailedCard> createState() => _QuizFailedCardState();
}

class _QuizFailedCardState extends State<QuizFailedCard>
    with TickerProviderStateMixin {
  // Animasi untuk kartu keseluruhan
  late AnimationController _cardController;
  late Animation<double> _cardScaleAnimation;

  // Animasi untuk ikon sad face
  late AnimationController _iconController;
  late Animation<double> _iconRotateAnimation;

  // Animasi untuk lingkaran skor
  late AnimationController _scoreController;
  late Animation<double> _scoreOpacityAnimation;
  late Animation<double> _scoreScaleAnimation;

  // Animasi untuk tombol
  late AnimationController _buttonController;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi kartu
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardScaleAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );

    // Inisialisasi animasi ikon
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _iconRotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));

    // Inisialisasi animasi skor
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Interval(0.4, 0.7, curve: Curves.easeIn),
    ));
    _scoreScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Interval(0.4, 0.8, curve: Curves.elasticOut),
    ));

    // Inisialisasi animasi tombol
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _buttonPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Memulai semua animasi secara bertahap
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _iconController.dispose();
    _scoreController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 480;

    // Menghitung ukuran berdasarkan layar
    final cardHeight = isSmallScreen ? 190.0 : (isMediumScreen ? 210.0 : 240.0);
    final circleSize = isSmallScreen ? 65.0 : (isMediumScreen ? 75.0 : 80.0);
    final titleFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final scoreFontSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 32.0);
    final messageFontSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final buttonFontSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final padding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final iconSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final maxLines = isSmallScreen ? 2 : 3;

    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Container(
        height: cardHeight,
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding / 2,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card dengan dekorasi sesuai spesifikasi
            Container(
              height: cardHeight,
              decoration: ShapeDecoration(
                color: CardColors.redPrimary.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: CardColors.redPrimary.shadow,
                    width: 3.0,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: CardColors.redPrimary.shadow,
                    blurRadius: 0,
                    offset: const Offset(4, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),

            // Konten kartu
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian atas dengan judul dan icon sad face
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian teks "Oops!"
                      Flexible(
                        child: FadeTransition(
                          opacity: _scoreOpacityAnimation,
                          child: Text(
                            "Oops!",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: titleFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Icon sad face di pojok kanan atas
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: RotationTransition(
                          turns: _iconRotateAnimation,
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 5 : 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.sentiment_dissatisfied,
                              color: CardColors.redPrimary.card,
                              size: isSmallScreen ? 18 : 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Skor di dalam lingkaran dan pesan
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lingkaran skor
                        ScaleTransition(
                          scale: _scoreScaleAnimation,
                          child: Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CardColors.redPrimary.shadow,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CardColors.redPrimary.shadow
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(seconds: 1),
                                builder: (context, value, child) {
                                  // Parsing score untuk animasi penghitungan
                                  final parts = widget.score.split('/');
                                  if (parts.length == 2) {
                                    final targetScore =
                                        int.tryParse(parts[0]) ?? 0;
                                    final totalScore =
                                        int.tryParse(parts[1]) ?? 10;
                                    final currentScore =
                                        (targetScore * value).round();
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "$currentScore/$totalScore",
                                        style: TextStyle(
                                          color: CardColors.redPrimary.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: scoreFontSize,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        widget.score,
                                        style: TextStyle(
                                          color: CardColors.redPrimary.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: scoreFontSize,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: isSmallScreen ? 8 : 12),

                        // Pesan motivasi
                        Expanded(
                          child: FadeTransition(
                            opacity: _scoreOpacityAnimation,
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: messageFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: maxLines,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol "Try Again"
                  Center(
                    child: ScaleTransition(
                      scale: _buttonPulseAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 6 : 8,
                          horizontal: isSmallScreen ? 12 : 16,
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: CardColors.redPrimary.shadow,
                              width: 2,
                            ),
                          ),
                          shadows: [
                            BoxShadow(
                              color: CardColors.redPrimary.shadow,
                              blurRadius: 0,
                              offset: const Offset(2, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: CardColors.redPrimary.card,
                                size: iconSize,
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 8),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Try Again",
                                    style: TextStyle(
                                      color: CardColors.redPrimary.text,
                                      fontWeight: FontWeight.bold,
                                      fontSize: buttonFontSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Elemen dekoratif - X marks
            ...List.generate(6, (index) {
              final random = math.Random(index);
              final top = random.nextDouble() * cardHeight;
              final left =
                  random.nextDouble() * (screenSize.width - padding * 2);
              final size = random.nextDouble() * 4 + 7;
              final opacity = random.nextDouble() * 0.3 + 0.1;

              return Positioned(
                top: top,
                left: left,
                child: AnimatedXMark(
                  size: size,
                  opacity: opacity,
                  animationController: _iconController,
                  index: index,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Widget untuk animasi tanda X
class AnimatedXMark extends StatelessWidget {
  final double size;
  final double opacity;
  final AnimationController animationController;
  final int index;

  const AnimatedXMark({
    Key? key,
    required this.size,
    required this.opacity,
    required this.animationController,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final rotation = (index % 2 == 0 ? 1 : -1) *
            math.pi *
            0.05 *
            animationController.value;

        return Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              child: Center(
                child: Text(
                  "✕",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuizCompletionCard extends StatefulWidget {
  final String score;
  final String message;

  const QuizCompletionCard({
    Key? key,
    required this.score,
    required this.message,
  }) : super(key: key);

  @override
  State<QuizCompletionCard> createState() => _QuizCompletionCardState();
}

class _QuizCompletionCardState extends State<QuizCompletionCard>
    with TickerProviderStateMixin {
  // Animasi untuk kartu keseluruhan
  late AnimationController _cardController;
  late Animation<double> _cardScaleAnimation;

  // Animasi untuk bintang
  late AnimationController _starController;
  late Animation<double> _starRotateAnimation;
  late Animation<double> _starScaleAnimation;

  // Animasi untuk konfeti
  late AnimationController _confetiController;
  late List<Animation<double>> _confetiAnimations;

  // Animasi untuk lingkaran skor
  late AnimationController _scoreController;
  late Animation<double> _scoreOpacityAnimation;
  late Animation<double> _scoreScaleAnimation;

  // Animasi untuk tombol
  late AnimationController _buttonController;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi kartu
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardScaleAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );

    // Inisialisasi animasi bintang
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _starRotateAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeInOut,
    ));
    _starScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeInOut,
    ));

    // Inisialisasi animasi konfeti
    _confetiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _confetiAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 0,
        end: 2 * math.pi,
      ).animate(CurvedAnimation(
        parent: _confetiController,
        curve: Interval(
          0.1 * index,
          0.1 * index + 0.8,
          curve: Curves.easeInOut,
        ),
      ));
    });

    // Inisialisasi animasi skor
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Interval(0.4, 0.7, curve: Curves.easeIn),
    ));
    _scoreScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Interval(0.4, 0.8, curve: Curves.elasticOut),
    ));

    // Inisialisasi animasi tombol
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _buttonPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Memulai semua animasi secara bertahap
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _starController.dispose();
    _confetiController.dispose();
    _scoreController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 480;

    // Menghitung ukuran berdasarkan layar
    final cardHeight = isSmallScreen ? 190.0 : (isMediumScreen ? 210.0 : 240.0);
    final circleSize = isSmallScreen ? 65.0 : (isMediumScreen ? 75.0 : 80.0);
    final titleFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final scoreFontSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 32.0);
    final messageFontSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final buttonFontSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final padding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final iconSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final maxLines = isSmallScreen ? 2 : 3;

    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Container(
        height: cardHeight,
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding / 2,
        ),
        child: Stack(
          clipBehavior: Clip.none, // Prevent clipping for the confetti effects
          children: [
            // Card dengan dekorasi sesuai spesifikasi
            Container(
              height: cardHeight,
              decoration: ShapeDecoration(
                color: CardColors.purplePrimary.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: CardColors.purplePrimary.shadow,
                    width: 3.0,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: CardColors.purplePrimary.shadow,
                    blurRadius: 0,
                    offset: const Offset(4, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),

            // Konten kartu
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian atas dengan judul dan bintang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian teks "Congratulation!"
                      Flexible(
                        child: FadeTransition(
                          opacity: _scoreOpacityAnimation,
                          child: Text(
                            "Congratulation!",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: titleFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Bintang di pojok kanan atas
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ScaleTransition(
                          scale: _starScaleAnimation,
                          child: RotationTransition(
                            turns: _starRotateAnimation,
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 5 : 8),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                                size: isSmallScreen ? 18 : 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Skor di dalam lingkaran dan pesan
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lingkaran skor
                        ScaleTransition(
                          scale: _scoreScaleAnimation,
                          child: Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CardColors.purplePrimary.shadow,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CardColors.purplePrimary.shadow
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(seconds: 1),
                                builder: (context, value, child) {
                                  // Parsing score untuk animasi penghitungan
                                  final parts = widget.score.split('/');
                                  if (parts.length == 2) {
                                    final targetScore =
                                        int.tryParse(parts[0]) ?? 0;
                                    final totalScore =
                                        int.tryParse(parts[1]) ?? 10;
                                    final currentScore =
                                        (targetScore * value).round();
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "$currentScore/$totalScore",
                                        style: TextStyle(
                                          color: CardColors.purplePrimary.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: scoreFontSize,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        widget.score,
                                        style: TextStyle(
                                          color: CardColors.purplePrimary.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: scoreFontSize,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: isSmallScreen ? 8 : 12),

                        // Pesan motivasi
                        Expanded(
                          child: FadeTransition(
                            opacity: _scoreOpacityAnimation,
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: messageFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: maxLines,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol "Close Dialog"
                  Center(
                    child: ScaleTransition(
                      scale: _buttonPulseAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 6 : 8,
                          horizontal: isSmallScreen ? 12 : 16,
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: CardColors.purplePrimary.shadow,
                              width: 2,
                            ),
                          ),
                          shadows: [
                            BoxShadow(
                              color: CardColors.purplePrimary.shadow,
                              blurRadius: 0,
                              offset: const Offset(2, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.replay_rounded,
                                color: CardColors.purplePrimary.card,
                                size: iconSize,
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 8),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Close Dialog",
                                    style: TextStyle(
                                      color: CardColors.purplePrimary.text,
                                      fontWeight: FontWeight.bold,
                                      fontSize: buttonFontSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Elemen dekoratif - konfeti yang berputar dan "falling"
            ...List.generate(8, (index) {
              // Reduced number of confetti
              // Posisi konfeti yang lebih acak dan menarik
              final random = math.Random(index);
              final top = random.nextDouble() * cardHeight;
              final left = random.nextDouble() * screenSize.width * 0.7;
              final size = random.nextDouble() * 5 + 8;
              final color = [
                Colors.yellow,
                Colors.pink,
                Colors.green,
                Colors.orange,
                Colors.cyan,
                Colors.purple,
                Colors.red,
              ][random.nextInt(7)];

              // Membuat konfeti dengan animasi jatuh dan berputar
              return Positioned(
                top: top,
                left: left,
                child: AnimatedConfetti(
                  color: color,
                  size: size,
                  animationController: _confetiController,
                  index: index,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Widget konfeti yang dianimasi
class AnimatedConfetti extends StatelessWidget {
  final Color color;
  final double size;
  final AnimationController animationController;
  final int index;

  const AnimatedConfetti({
    Key? key,
    required this.color,
    required this.size,
    required this.animationController,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Membuat animasi berputar
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final animationValue = animationController.value;

        // Animasi jatuh
        final fallDistance = 20.0 * animationValue;

        // Animasi berputar
        final rotation = (index % 2 == 0 ? 1 : -1) *
            math.pi *
            2 *
            animationValue *
            (index % 3 + 1);

        // Animasi muncul dan menghilang
        final opacity = math.sin(math.pi * animationValue) * 0.8 + 0.2;

        return Transform.translate(
          offset: Offset(0, fallDistance),
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: index % 3 != 0 ? BorderRadius.circular(2) : null,
        ),
      ),
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
