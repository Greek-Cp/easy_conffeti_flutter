import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../enums/confetti_enums.dart';
import '../models/card_color_model.dart';
import '../models/card_colors.dart';
import '../painters/confetti_painter.dart';

/// Widget that renders the confetti animation dialog

class ConfettiDialog extends StatefulWidget {
  final ConfettiType confettiType;
  final ConfettiStyle confettiStyle;
  final AnimationConfetti animationStyle;
  final ConfettiColorTheme colorTheme;
  final String? message;
  final bool useExternalController;
  final AnimationController? externalController;
  final int durationInSeconds;
  final ConfettiDensity density;
  final BlendMode? blendMode;
  final VoidCallback? onComplete;

  /// [NEW] menandakan bahwa kita mau me-random warna partikel dari [card, shadow, text]
  final bool isColorMixedFromModel;

  const ConfettiDialog({
    Key? key,
    required this.confettiType,
    required this.confettiStyle,
    required this.animationStyle,
    this.colorTheme = ConfettiColorTheme.rainbow,
    this.message,
    required this.useExternalController,
    this.externalController,
    this.durationInSeconds = 4,
    this.density = ConfettiDensity.medium,
    this.blendMode,
    this.onComplete,
    this.isColorMixedFromModel = false, // default false
  }) : super(key: key);

  @override
  State<ConfettiDialog> createState() => _ConfettiDialogState();
}

class _ConfettiDialogState extends State<ConfettiDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _usingInternalController = false;

  // For fade/scale
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // For particle physics
  late AnimationController _physicsController;
  late Animation<double> _physicsAnimation;

  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Main controller
    if (widget.useExternalController && widget.externalController != null) {
      _animationController = widget.externalController!;
      _usingInternalController = false;
    } else {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: widget.durationInSeconds),
      );
      _usingInternalController = true;
    }

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    )..addListener(() {
        setState(() {});
      });

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _physicsController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );
    _physicsAnimation = CurvedAnimation(
      parent: _physicsController,
      curve: Curves.linear,
    );

    _generateParticles();

    _animationController.forward();
    _physicsController.repeat();

    if (_usingInternalController) {
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    if (_usingInternalController) {
      _animationController.dispose();
    }
    _physicsController.dispose();
    super.dispose();
  }

  void _generateParticles() {
    final rand = math.Random();

    int quantity;
    switch (widget.density) {
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
    if (widget.confettiType == ConfettiType.celebration ||
        widget.confettiType == ConfettiType.levelUp) {
      quantity = (quantity * 1.5).round();
    }

    for (int i = 0; i < quantity; i++) {
      // Start pos
      Offset position;
      switch (widget.animationStyle) {
        case AnimationConfetti.fountain:
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
          position = Offset(rand.nextDouble(), 0.5);
          break;
      }

      double speed = rand.nextDouble() * 2 + 0.5;
      Offset velocity;
      switch (widget.animationStyle) {
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

      Color color = _getColorFromTheme(rand);

      double size = 5.0 + rand.nextDouble() * 5.0;
      if (widget.confettiStyle == ConfettiStyle.star ||
          widget.confettiStyle == ConfettiStyle.emoji) {
        size *= 1.5;
      }

      double rotationSpeed = 0.0;
      if (widget.confettiStyle == ConfettiStyle.star ||
          widget.confettiStyle == ConfettiStyle.ribbons ||
          widget.confettiStyle == ConfettiStyle.paper) {
        rotationSpeed = (rand.nextDouble() - 0.5) * 10.0;
      }

      String? emoji;
      if (widget.confettiStyle == ConfettiStyle.emoji) {
        emoji = _getRandomEmoji(widget.confettiType);
      }

      // Create the appropriate shape renderer based on confetti style
      ParticleShapeRenderer shapeRenderer;
      switch (widget.confettiStyle) {
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

  /// [MODIFIED] Jika colorTheme adalah salah satu yang mapping ke CardColorModel
  /// dan [isColorMixedFromModel] = true, maka ambil acak di antara [card, shadow, text].
  Color _getColorFromTheme(math.Random rand) {
    switch (widget.colorTheme) {
      // Warna acak (rainbow, pastel, dsb.) => tetap
      case ConfettiColorTheme.rainbow:
        return HSVColor.fromAHSV(
          1.0,
          rand.nextDouble() * 360.0,
          0.8 + rand.nextDouble() * 0.2,
          0.8 + rand.nextDouble() * 0.2,
        ).toColor();
      case ConfettiColorTheme.pastel:
        return HSVColor.fromAHSV(
          1.0,
          rand.nextDouble() * 360.0,
          0.4 + rand.nextDouble() * 0.3,
          0.9 + rand.nextDouble() * 0.1,
        ).toColor();
      case ConfettiColorTheme.neon:
        List<Color> neonColors = [
          Colors.deepPurple.shade300,
          Colors.pinkAccent.shade200,
          Colors.cyanAccent.shade200,
          Colors.greenAccent.shade400,
          Colors.amberAccent.shade400,
        ];
        return neonColors[rand.nextInt(neonColors.length)];
      case ConfettiColorTheme.gold:
        return HSVColor.fromAHSV(
          1.0,
          40.0 + rand.nextDouble() * 20.0,
          0.7 + rand.nextDouble() * 0.3,
          0.8 + rand.nextDouble() * 0.2,
        ).toColor();
      case ConfettiColorTheme.silver:
        return Color.fromRGBO(
          (220 + rand.nextInt(35)).clamp(0, 255),
          (220 + rand.nextInt(35)).clamp(0, 255),
          (220 + rand.nextInt(35)).clamp(0, 255),
          1.0,
        );
      case ConfettiColorTheme.festive:
        List<Color> festiveColors = [
          Colors.red.shade500,
          Colors.green.shade500,
          Colors.white,
          Colors.red.shade700,
          Colors.green.shade700,
        ];
        return festiveColors[rand.nextInt(festiveColors.length)];
      case ConfettiColorTheme.birthday:
        List<Color> birthdayColors = [
          Colors.pink.shade300,
          Colors.lightBlue.shade300,
          Colors.yellow.shade300,
          Colors.purple.shade300,
          Colors.orange.shade300,
        ];
        return birthdayColors[rand.nextInt(birthdayColors.length)];

      // Kategori CardColorModel
      case ConfettiColorTheme.orange:
        return _getModelColor(rand, CardColors.orangePrimary);
      case ConfettiColorTheme.teal:
        return _getModelColor(rand, CardColors.tealPrimary);
      case ConfettiColorTheme.blue:
        return _getModelColor(rand, CardColors.bluePrimary);
      case ConfettiColorTheme.purple:
        return _getModelColor(rand, CardColors.purplePrimary);
      case ConfettiColorTheme.pink:
        return _getModelColor(rand, CardColors.pinkPrimary);
      case ConfettiColorTheme.magenta:
        return _getModelColor(rand, CardColors.magentaPrimary);
      case ConfettiColorTheme.red:
        return _getModelColor(rand, CardColors.redPrimary);
      case ConfettiColorTheme.yellow:
        return _getModelColor(rand, CardColors.yellowPrimary);
      case ConfettiColorTheme.lime:
        return _getModelColor(rand, CardColors.limePrimary);
      case ConfettiColorTheme.lightGreen:
        return _getModelColor(rand, CardColors.lightGreenPrimary);
      case ConfettiColorTheme.green:
        return _getModelColor(rand, CardColors.greenPrimary);
      case ConfettiColorTheme.gray:
        return _getModelColor(rand, CardColors.grayPrimary);

      case ConfettiColorTheme.custom:
        // (Logika custom, sesuai confettiType)
        if (widget.confettiType == ConfettiType.success) {
          List<Color> successColors = [
            Colors.green.shade400,
            Colors.green.shade300,
            Colors.lightGreen.shade300,
            Colors.amber.shade300,
            Colors.yellow.shade300,
          ];
          return successColors[rand.nextInt(successColors.length)];
        } else if (widget.confettiType == ConfettiType.failed) {
          List<Color> failedColors = [
            Colors.blue.shade300,
            Colors.lightBlue.shade200,
            Colors.purple.shade200,
            Colors.indigo.shade200,
          ];
          return failedColors[rand.nextInt(failedColors.length)];
        } else if (widget.confettiType == ConfettiType.achievement) {
          List<Color> achievementColors = [
            Colors.amber.shade400,
            Colors.amber.shade300,
            Colors.purple.shade300,
            Colors.deepPurple.shade300,
          ];
          return achievementColors[rand.nextInt(achievementColors.length)];
        }
        // Default rainbow
        return HSVColor.fromAHSV(
          1.0,
          rand.nextDouble() * 360.0,
          0.8 + rand.nextDouble() * 0.2,
          0.8 + rand.nextDouble() * 0.2,
        ).toColor();
    }
  }

  /// [NEW] Memilih warna dari CardColorModel
  /// jika isColorMixedFromModel = true => pick random [model.card, model.shadow, model.text]
  /// jika false => return model.card (default).
  Color _getModelColor(math.Random rand, CardColorModel model) {
    if (widget.isColorMixedFromModel) {
      // Ambil salah satu dari 3
      final colorList = [model.card, model.shadow, model.text];
      return colorList[rand.nextInt(colorList.length)];
    } else {
      // tetap pakai card
      return model.card;
    }
  }

  /// Pilih emoji acak
  String _getRandomEmoji(ConfettiType type) {
    final rand = math.Random();
    switch (type) {
      case ConfettiType.success:
        List<String> successEmojis = ['🎉', '👍', '✅', '🏆', '⭐', '💯', '🥇'];
        return successEmojis[rand.nextInt(successEmojis.length)];
      case ConfettiType.failed:
        List<String> failedEmojis = ['🎮', '🔄', '🚀', '💪', '✨', '👾', '🎯'];
        return failedEmojis[rand.nextInt(failedEmojis.length)];
      case ConfettiType.celebration:
        List<String> celebrationEmojis = [
          '🎉',
          '🎊',
          '🥳',
          '🎈',
          '🎂',
          '🎁',
          '💃',
          '🕺'
        ];
        return celebrationEmojis[rand.nextInt(celebrationEmojis.length)];
      case ConfettiType.achievement:
        List<String> achievementEmojis = [
          '🏆',
          '🥇',
          '🏅',
          '⭐',
          '✨',
          '💪',
          '👑'
        ];
        return achievementEmojis[rand.nextInt(achievementEmojis.length)];
      case ConfettiType.levelUp:
        List<String> levelUpEmojis = ['⬆️', '🚀', '💯', '⚡', '🔥', '🌟', '🆙'];
        return levelUpEmojis[rand.nextInt(levelUpEmojis.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          children: [
            // layer confetti
            SizedBox.expand(
              child: CustomPaint(
                painter: ConfettiPainter(
                  particles: _particles,
                  animationValue: _animation.value,
                  physicsValue: _physicsAnimation.value,
                  confettiType: widget.confettiType,
                  confettiStyle: widget.confettiStyle,
                  animationStyle: widget.animationStyle,
                  blendMode: widget.blendMode,
                ),
              ),
            ),

            // optional message
            if (widget.message != null)
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return AnimatedOpacity(
                      opacity: _fadeAnimation.value,
                      duration: const Duration(milliseconds: 300),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
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
                            widget.message!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getMessageColor(),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // optional close
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return AnimatedOpacity(
                      opacity: _animation.value > 0.5 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: () {
                          if (widget.onComplete != null) {
                            widget.onComplete!();
                          }
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: _getMessageColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMessageColor() {
    switch (widget.confettiType) {
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
}
