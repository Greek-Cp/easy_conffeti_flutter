import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Enum untuk jenis animasi konfeti (dibatasi hanya 2)
enum ConfettiAnimation {
  rain,
  explode,
}

// Model untuk warna kartu
class CardColorModel {
  final Color card;
  final Color shadow;
  CardColorModel({required this.card, required this.shadow});

  // Mendapatkan variasi warna dari model kartu
  List<Color> getColorVariations() {
    // Membuat variasi lebih banyak untuk pilihan acak
    return [
      card,
      shadow,
      Color.lerp(card, shadow, 0.5) ?? card,
      card.withOpacity(0.7),
      shadow.withOpacity(0.7),
      HSLColor.fromColor(card)
          .withLightness(
              (HSLColor.fromColor(card).lightness + 0.2).clamp(0.0, 1.0))
          .toColor(),
      HSLColor.fromColor(card)
          .withSaturation(
              (HSLColor.fromColor(card).saturation - 0.1).clamp(0.0, 1.0))
          .toColor(),
      HSLColor.fromColor(shadow)
          .withLightness(
              (HSLColor.fromColor(shadow).lightness + 0.15).clamp(0.0, 1.0))
          .toColor(),
    ];
  }
}

// Warna-warna kartu preset
class CardColors {
  static CardColorModel purpleDark = CardColorModel(
    card: const Color(0xFF4A148C),
    shadow: const Color(0xFF311B92),
  );
  static CardColorModel purplePrimary = CardColorModel(
    card: const Color(0xFF9C27B0),
    shadow: const Color(0xFF7B1FA2),
  );
  static CardColorModel blueSecondary = CardColorModel(
    card: const Color(0xFF2196F3),
    shadow: const Color(0xFF1976D2),
  );
  static CardColorModel pinkBlue = CardColorModel(
    card: const Color(0xFFE91E63),
    shadow: const Color(0xFFAD1457),
  );

  // Getter untuk mendapatkan semua warna
  static List<CardColorModel> get allColors =>
      [purpleDark, purplePrimary, blueSecondary, pinkBlue];

  // Mendapatkan warna random
  static CardColorModel getRandom() {
    return allColors[math.Random().nextInt(allColors.length)];
  }
}

// Enum untuk tipe partikel
enum ParticleType {
  emoji,
  text,
  circle,
}

// Data konfigurasi partikel
class ParticleData {
  final ParticleType type;
  final int count;
  final String? emoji;
  final String? text;
  final TextStyle? textStyle;
  final Color color;
  final double size;
  final double speedParticle;
  final bool isLoopParticle;
  final int durationIntervalMs;
  final bool useCardColor;
  final bool preserveEmojiColor;
  final bool leavesTrail; // Apakah meninggalkan partikel trail
  final int trailDecayMs; // Waktu untuk trail menghilang

  ParticleData({
    required this.type,
    required this.count,
    this.emoji,
    this.text,
    this.textStyle,
    required this.color,
    required this.size,
    required this.speedParticle,
    required this.isLoopParticle,
    required this.durationIntervalMs,
    this.useCardColor = true,
    this.preserveEmojiColor = true,
    this.leavesTrail = false,
    this.trailDecayMs = 500, // Trail menghilang lebih cepat dari partikel utama
  });
}

// Class utama widget konfeti
class OptimizedConfetti extends StatefulWidget {
  final bool isPlaying;
  final List<ParticleData> particles;
  final CardColorModel cardColor;
  final ConfettiAnimation animation;
  final Duration duration;
  final bool shouldLoop;
  final bool enableTapEffect;
  final Color backgroundColor;

  const OptimizedConfetti({
    Key? key,
    this.isPlaying = true,
    required this.particles,
    required this.cardColor,
    this.animation = ConfettiAnimation.rain,
    this.duration = const Duration(seconds: 5),
    this.shouldLoop = false,
    this.enableTapEffect = true,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  OptimizedConfettiState createState() => OptimizedConfettiState();
}

class OptimizedConfettiState extends State<OptimizedConfetti>
    with SingleTickerProviderStateMixin {
  late final ParticleSystem _particleSystem;
  late final Ticker _ticker;
  bool _isPlaying = false;
  Timer? _loopTimer;

  // Cache untuk pre-rendered textures
  final Map<String, ui.Image> _textureCache = {};
  final List<Offset> _tapPositions = [];

  // Stats untuk auto-tuning
  int _frameCount = 0;
  int _lastFrameTime = 0;
  double _currentFps = 60.0;
  int _adaptiveParticleCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize particle system
    _particleSystem = ParticleSystem(
      particleDataList: widget.particles,
      cardColor: widget.cardColor,
      animation: widget.animation,
    );

    // Set adaptive particle count based on total from all ParticleData
    _adaptiveParticleCount =
        widget.particles.fold(0, (sum, data) => sum + data.count);

    // Initialize ticker for animation
    _ticker = createTicker(_onTick);

    // Pre-cache textures
    _preRenderTextures();

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  // Pre-render textures for better performance
  Future<void> _preRenderTextures() async {
    // Pre-render for each particle data
    for (final particleData in widget.particles) {
      if (particleData.type == ParticleType.emoji &&
          particleData.emoji != null) {
        // Pre-render emoji
        final emoji = particleData.emoji!;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        final textPainter = TextPainter(
          text: TextSpan(
            text: emoji,
            style: TextStyle(fontSize: particleData.size),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset.zero);

        final picture = recorder.endRecording();
        final image = await picture.toImage(
            textPainter.width.ceil(), textPainter.height.ceil());

        _textureCache[emoji] = image;
      } else if (particleData.type == ParticleType.text &&
          particleData.text != null) {
        // Pre-render text
        final text = particleData.text!;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: particleData.textStyle ??
                TextStyle(
                  fontSize: particleData.size,
                  fontWeight: FontWeight.bold,
                  color: particleData.color,
                ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset.zero);

        final picture = recorder.endRecording();
        final image = await picture.toImage(
            textPainter.width.ceil(), textPainter.height.ceil());

        _textureCache[text] = image;
      }
    }
  }

  void _onTick(Duration elapsed) {
    // Calculate delta time for smooth animation across devices
    final now = DateTime.now().millisecondsSinceEpoch;
    final deltaTime =
        _lastFrameTime > 0 ? (now - _lastFrameTime) / 1000.0 : 0.016;
    _lastFrameTime = now;

    // Calculate current FPS for adaptive particle count
    _frameCount++;
    if (_frameCount >= 30) {
      _currentFps = 30 / deltaTime / 30;
      _frameCount = 0;

      // Auto-tune particle count based on performance
      if (_currentFps < 30 && _adaptiveParticleCount > 20) {
        _adaptiveParticleCount = (_adaptiveParticleCount * 0.8).toInt();
        _particleSystem.limitActiveParticles(_adaptiveParticleCount);
      } else if (_currentFps > 55 &&
          _adaptiveParticleCount <
              widget.particles.fold(0, (sum, data) => sum + data.count)) {
        _adaptiveParticleCount = math.min(
            (_adaptiveParticleCount * 1.2).toInt(),
            widget.particles.fold(0, (sum, data) => sum + data.count));
      }
    }

    // Process tap positions
    if (_tapPositions.isNotEmpty) {
      for (final position in _tapPositions) {
        _particleSystem.emitAt(
          position,
          math.min(20, _adaptiveParticleCount ~/ 5),
          ConfettiAnimation.explode,
        );
      }
      _tapPositions.clear();
    }

    // Update particle system
    _particleSystem.update(deltaTime);

    // Trigger repaint
    setState(() {});
  }

  void _startConfetti() {
    if (!_isPlaying) {
      _isPlaying = true;
      _ticker.start();

      // Reset system and emit initial particles
      _particleSystem.reset();
      _particleSystem.emit(_adaptiveParticleCount, widget.animation);

      // Setup loop timer if needed
      if (widget.shouldLoop) {
        _loopTimer = Timer.periodic(widget.duration, (_) {
          _particleSystem.emit(_adaptiveParticleCount, widget.animation);
        });
      } else {
        // Stop after duration
        Future.delayed(widget.duration, () {
          if (mounted) {
            _stopConfetti();
          }
        });
      }
    }
  }

  void _stopConfetti() {
    if (_isPlaying) {
      _isPlaying = false;
      _ticker.stop();
      _loopTimer?.cancel();
      _loopTimer = null;
    }
  }

  // Add tap position for particle emission
  void _addTapPosition(Offset position) {
    if (widget.enableTapEffect && _isPlaying) {
      _tapPositions.add(position);
    }
  }

  @override
  void didUpdateWidget(OptimizedConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update particle system properties if card color changes
    if (widget.cardColor != oldWidget.cardColor) {
      _particleSystem.setCardColor(widget.cardColor);
    }

    // Update animation type if changed
    if (widget.animation != oldWidget.animation) {
      _particleSystem.setAnimation(widget.animation);
    }

    // Handle play state changes
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startConfetti();
      } else {
        _stopConfetti();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) => _addTapPosition(details.localPosition),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: widget.backgroundColor,
        child: CustomPaint(
          painter: ConfettiPainter(
            particles: _particleSystem.particles,
            textureCache: _textureCache,
          ),
        ),
      ),
    );
  }
}

// Particle class for storing particle data
class Particle {
  double x;
  double y;
  double vx = 0;
  double vy = 0;
  double alpha = 1.0;
  double rotation = 0;
  double rotationSpeed = 0;
  double scale = 1.0;
  ParticleType type;
  String content = '';
  Color color;
  double size;
  bool isActive = true;
  int lifetimeMs;
  int createdAtMs;
  bool loop;
  bool preserveEmojiColor;
  bool isTrail = false; // Indikator apakah partikel ini adalah trail
  bool leavesTrail = false; // Apakah meninggalkan partikel trail
  int trailEmitTimer = 0; // Timer untuk emisi trail
  int trailDecayMs = 500; // Waktu untuk menghilangkan trail

  Particle({
    required this.x,
    required this.y,
    required this.type,
    required this.color,
    required this.size,
    required this.lifetimeMs,
    this.loop = false,
    this.preserveEmojiColor = true,
    this.leavesTrail = false,
    this.isTrail = false,
    this.trailDecayMs = 500,
  }) : createdAtMs = DateTime.now().millisecondsSinceEpoch;

  // Get position as Offset for quad tree
  Offset get position => Offset(x, y);

  // Get bounds for quad tree
  Rect get bounds => Rect.fromCenter(
        center: Offset(x, y),
        width: size * scale,
        height: size * scale,
      );

  // Check if particle is expired
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    return !loop && (now - createdAtMs > lifetimeMs);
  }

  // Calculate remaining lifetime percentage
  double get lifetimePercentage {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - createdAtMs;
    return loop
        ? 1.0
        : math.max(0.0, math.min(1.0, 1.0 - (elapsed / lifetimeMs)));
  }
}

// Particle system for managing particles
class ParticleSystem {
  final List<Particle> particles = [];
  final List<Particle> _particlePool = [];
  final math.Random _random = math.Random();

  // Parameters
  final List<ParticleData> particleDataList;
  CardColorModel cardColor;
  List<Color> cardColorVariations = [];
  List<Color> currentActiveColors = []; // 3 warna acak yang digunakan saat ini
  ConfettiAnimation animation;
  int _maxActiveParticles = 0;

  // List emoji dan text untuk random selection
  final List<String> _allEmojis = [
    '🎉',
    '🎊',
    '✨',
    '⭐',
    '🌟',
    '💫',
    '🎇',
    '🎆',
    '🎁',
    '🎀',
    '🎵',
    '🎸',
    '🎺',
    '🎮',
    '🎯',
    '🏆',
    '🍕',
    '🍦',
    '🧁',
    '🍭'
  ];

  final List<String> _allTexts = [
    'WOW',
    'YAY',
    'COOL',
    'AWESOME',
    'FUN',
    'SUPER',
    'GREAT',
    'NICE',
    'YES',
    'WIN'
  ];

  // Random subset untuk penggunaan saat ini
  List<String> _currentEmojis = [];
  List<String> _currentTexts = [];

  // Spatial partitioning for optimization
  final QuadTree _quadTree = QuadTree(
    boundary: const Rect.fromLTWH(0, 0, 1000, 2000),
    capacity: 10,
  );

  ParticleSystem({
    required this.particleDataList,
    required this.cardColor,
    this.animation = ConfettiAnimation.rain,
  }) {
    // Generate color variations from card color
    cardColorVariations = cardColor.getColorVariations();

    // Pilih 3 warna acak dari variasi
    _selectRandomColors();

    // Choose random emoji dan text subsets
    _selectRandomParticleContent();

    // Pre-allocate particle pool (object pooling)
    _initializeParticlePool(500);
  }

  // Pilih 3 warna acak dari variasi kartu
  void _selectRandomColors() {
    cardColorVariations.shuffle(_random);
    currentActiveColors = cardColorVariations.take(3).toList();
  }

  // Pilih subset random dari emoji dan text
  void _selectRandomParticleContent() {
    _allEmojis.shuffle(_random);
    _allTexts.shuffle(_random);

    _currentEmojis = _allEmojis.take(3).toList();
    _currentTexts = _allTexts.take(3).toList();
  }

  // Initialize particle pool for reuse
  void _initializeParticlePool(int count) {
    for (int i = 0; i < count; i++) {
      _particlePool.add(Particle(
        x: 0,
        y: 0,
        type: ParticleType.circle,
        color: Colors.white,
        size: 10,
        lifetimeMs: 3000,
      ));
    }
  }

  // Get particle from pool or create new one
  Particle _getParticle(ParticleData data, {bool isTrail = false}) {
    if (_particlePool.isNotEmpty) {
      Particle particle = _particlePool.removeLast();

      // Reset particle with new data
      particle.type = data.type;

      // Set color based on settings
      if (data.useCardColor) {
        // Pilih warna acak dari 3 warna aktif
        particle.color =
            currentActiveColors[_random.nextInt(currentActiveColors.length)];
      } else {
        particle.color = data.color;
      }

      particle.size =
          isTrail ? data.size * 0.5 : data.size; // Trail lebih kecil
      particle.lifetimeMs =
          isTrail ? data.trailDecayMs : data.durationIntervalMs;
      particle.loop = data.isLoopParticle && !isTrail; // Trail tidak diloop
      particle.createdAtMs = DateTime.now().millisecondsSinceEpoch;
      particle.preserveEmojiColor = data.preserveEmojiColor;
      particle.isTrail = isTrail;
      particle.leavesTrail =
          !isTrail && data.leavesTrail; // Trail tidak membuat trail lagi
      particle.trailDecayMs = data.trailDecayMs;

      return particle;
    }

    // If pool is empty, create new particle
    return Particle(
      x: 0,
      y: 0,
      type: data.type,
      color: data.useCardColor
          ? currentActiveColors[_random.nextInt(currentActiveColors.length)]
          : data.color,
      size: isTrail ? data.size * 0.5 : data.size,
      lifetimeMs: isTrail ? data.trailDecayMs : data.durationIntervalMs,
      loop: data.isLoopParticle && !isTrail,
      preserveEmojiColor: data.preserveEmojiColor,
      leavesTrail: !isTrail && data.leavesTrail,
      isTrail: isTrail,
      trailDecayMs: data.trailDecayMs,
    );
  }

  // Return particle to pool
  void _recycleParticle(Particle particle) {
    particle.isActive = false;
    _particlePool.add(particle);
  }

  // Emit particles with specific animation
  void emit(int count, ConfettiAnimation animationType) {
    // Pilih 3 warna acak baru
    _selectRandomColors();

    // Pilih emoji dan text baru secara random
    _selectRandomParticleContent();

    // Calculate particles per data type
    final totalRequestedCount =
        particleDataList.fold(0, (sum, data) => sum + data.count);
    final scaleFactor =
        totalRequestedCount > 0 ? count / totalRequestedCount : 0;

    for (final data in particleDataList) {
      final adjustedCount = (data.count * scaleFactor).round();

      for (int i = 0; i < adjustedCount; i++) {
        final particle = _getParticle(data);

        // Reset particle
        particle.isActive = true;
        particle.alpha = 1.0;
        particle.scale = 0.5 + _random.nextDouble() * 0.5;
        particle.rotation = _random.nextDouble() * 2 * math.pi;
        particle.rotationSpeed = (_random.nextDouble() - 0.5) * 2;

        // Set content based on type
        if (data.type == ParticleType.emoji) {
          // Gunakan emoji random dari subset terpilih
          particle.content =
              _currentEmojis[_random.nextInt(_currentEmojis.length)];
        } else if (data.type == ParticleType.text) {
          // Gunakan text random dari subset terpilih
          particle.content =
              _currentTexts[_random.nextInt(_currentTexts.length)];
        }

        // Set initial position and velocity based on animation type
        if (animationType == ConfettiAnimation.rain) {
          // For rain animation, start at top with randomized x
          particle.x = _random.nextDouble() * 1000;
          particle.y = -50 - _random.nextDouble() * 100;
          particle.vx = (_random.nextDouble() - 0.5) * 100 * data.speedParticle;
          particle.vy = 100 + _random.nextDouble() * 200 * data.speedParticle;
        } else if (animationType == ConfettiAnimation.explode) {
          // For explode animation, start at center
          particle.x = 500;
          particle.y = 800;

          // Random direction with random speed
          final angle = _random.nextDouble() * 2 * math.pi;
          final speed = 300 + _random.nextDouble() * 500 * data.speedParticle;
          particle.vx = math.cos(angle) * speed;
          particle.vy = math.sin(angle) * speed;
        }

        particles.add(particle);
        _quadTree.insert(particle);
      }
    }
  }

  // Emit particles at specific position (tap effect)
  void emitAt(Offset position, int count, ConfettiAnimation animationType) {
    // Pilih 3 warna acak baru untuk tap effect
    _selectRandomColors();

    // Pilih emoji dan text baru secara random untuk tap effect
    _selectRandomParticleContent();

    // Calculate particles per data type
    final totalRequestedCount =
        particleDataList.fold(0, (sum, data) => sum + data.count);
    final scaleFactor =
        totalRequestedCount > 0 ? count / totalRequestedCount : 0;

    for (final data in particleDataList) {
      final adjustedCount = (data.count * scaleFactor).round();

      for (int i = 0; i < adjustedCount; i++) {
        final particle = _getParticle(data);

        // Reset particle
        particle.isActive = true;
        particle.alpha = 1.0;
        particle.scale = 0.5 + _random.nextDouble() * 0.5;
        particle.rotation = _random.nextDouble() * 2 * math.pi;
        particle.rotationSpeed = (_random.nextDouble() - 0.5) * 2;

        // Set content based on type
        if (data.type == ParticleType.emoji) {
          // Gunakan emoji random dari subset terpilih
          particle.content =
              _currentEmojis[_random.nextInt(_currentEmojis.length)];
        } else if (data.type == ParticleType.text) {
          // Gunakan text random dari subset terpilih
          particle.content =
              _currentTexts[_random.nextInt(_currentTexts.length)];
        }

        // Set initial position at tap position
        particle.x = position.dx;
        particle.y = position.dy;

        // Burst pattern for tap
        final angle = _random.nextDouble() * 2 * math.pi;
        final speed = 200 + _random.nextDouble() * 300 * data.speedParticle;
        particle.vx = math.cos(angle) * speed;
        particle.vy = math.sin(angle) * speed;

        particles.add(particle);
        _quadTree.insert(particle);
      }
    }
  }

  // Emit trail particle at the position of main particle
  void _emitTrailParticle(Particle mainParticle, ParticleData originalData) {
    // Create trail particle
    final trailParticle = _getParticle(originalData, isTrail: true);

    // Copy position from main particle
    trailParticle.x = mainParticle.x;
    trailParticle.y = mainParticle.y;
    trailParticle.rotation = mainParticle.rotation;

    // Kurangi velocity untuk trail
    trailParticle.vx = mainParticle.vx * 0.1; // Hampir tidak bergerak
    trailParticle.vy = mainParticle.vy * 0.1; // Hampir tidak bergerak

    // Set alpha and scale for fade effect
    trailParticle.alpha = 0.5;
    trailParticle.scale = mainParticle.scale * 0.7;

    // For emoji and text, use same content as main particle
    trailParticle.content = mainParticle.content;

    // Gunakan warna yang lebih pudar dari main particle
    if (originalData.useCardColor) {
      // Optional: buat trail sedikit lebih pudar
      trailParticle.color = mainParticle.color.withOpacity(0.8);
    }

    // Add to particles
    particles.add(trailParticle);
    _quadTree.insert(trailParticle);
  }

  // Update all particles
  void update(double deltaTime) {
    // Rebuild quad tree (clear and rebuild is faster than updating)
    _quadTree.clear();

    // Find the original data for each particle type to use for trails
    final Map<ParticleType, ParticleData> originalDataMap = {};
    for (final data in particleDataList) {
      originalDataMap[data.type] = data;
    }

    // Use indexed for loop for better performance when removing items
    for (int i = particles.length - 1; i >= 0; i--) {
      final particle = particles[i];

      // Skip inactive particles
      if (!particle.isActive) continue;

      // Check for expired particles
      if (particle.isExpired) {
        // If looped, reset but keep active
        if (particle.loop) {
          particle.createdAtMs = DateTime.now().millisecondsSinceEpoch;

          // Reset position based on current animation
          if (animation == ConfettiAnimation.rain) {
            particle.x = _random.nextDouble() * 1000;
            particle.y = -50;
            particle.vx = (_random.nextDouble() - 0.5) * 100;
            particle.vy = 100 + _random.nextDouble() * 200;
          } else if (animation == ConfettiAnimation.explode) {
            particle.x = 500;
            particle.y = 800;
            final angle = _random.nextDouble() * 2 * math.pi;
            final speed = 300 + _random.nextDouble() * 500;
            particle.vx = math.cos(angle) * speed;
            particle.vy = math.sin(angle) * speed;
          }
        } else {
          // Recycle non-looping expired particles
          _recycleParticle(particle);
          particles.removeAt(i);
          continue;
        }
      }

      // Create trail particles if needed (hanya untuk partikel non-trail)
      if (particle.leavesTrail && !particle.isTrail) {
        particle.trailEmitTimer += (deltaTime * 1000).round();

        // Emit trail particle every ~70ms (kalau kecepatan cukup)
        if (particle.trailEmitTimer > 70 &&
            (math.sqrt(particle.vx * particle.vx + particle.vy * particle.vy) >
                50)) {
          particle.trailEmitTimer = 0;

          // Get original data for this particle type
          final originalData = originalDataMap[particle.type];
          if (originalData != null) {
            _emitTrailParticle(particle, originalData);
          }
        }
      }

      // Apply physics - non-trail particle
      if (!particle.isTrail) {
        particle.vy += 9.8 * deltaTime * 30; // Gravity
        particle.vx +=
            (_random.nextDouble() - 0.5) * 5 * deltaTime; // Slight wind/drift

        // Apply drag (air resistance)
        particle.vx *= 0.98;
        particle.vy *= 0.98;

        // Update position
// Update position
        particle.x += particle.vx * deltaTime;
        particle.y += particle.vy * deltaTime;
      } else {
        // Trail khusus - hanya fade out, hampir tidak bergerak
        particle.vx *= 0.9; // Mengurangi kecepatan dengan cepat
        particle.vy *= 0.9;

        // Pergerakan minimal
        particle.x += particle.vx * deltaTime * 0.1;
        particle.y += particle.vy * deltaTime * 0.1;
      }

      // Update rotation
      particle.rotation += particle.rotationSpeed * deltaTime;

      // Update alpha based on lifetime
      if (!particle.loop) {
        particle.alpha = particle.lifetimePercentage;
      }

      // Remove particles that are off-screen
      if (particle.y > 2000 || particle.x < -100 || particle.x > 1100) {
        if (particle.loop) {
          // Reset position for looping particles
          particle.x = _random.nextDouble() * 1000;
          particle.y = -50;
          particle.vx = (_random.nextDouble() - 0.5) * 100;
          particle.vy = 100 + _random.nextDouble() * 200;
        } else {
          _recycleParticle(particle);
          particles.removeAt(i);
          continue;
        }
      }

      // Insert into quad tree for spatial queries
      _quadTree.insert(particle);
    }

    // Limit active particles if needed
    limitActiveParticles(_maxActiveParticles);
  }

  // Reset the system
  void reset() {
    // Recycle all particles
    for (final particle in particles) {
      _recycleParticle(particle);
    }
    particles.clear();
    _quadTree.clear();
  }

  // Limit active particles for performance
  void limitActiveParticles(int maxCount) {
    _maxActiveParticles = maxCount;

    if (maxCount <= 0 || particles.length <= maxCount) return;

    // Sort by alpha (remove most faded first)
    particles.sort((a, b) => a.alpha.compareTo(b.alpha));

    // Recycle excess particles
    final excessCount = particles.length - maxCount;
    for (int i = 0; i < excessCount; i++) {
      _recycleParticle(particles[i]);
    }

    // Remove recycled particles
    particles.removeRange(0, excessCount);
  }

  // Set animation type
  void setAnimation(ConfettiAnimation anim) {
    animation = anim;
  }

  // Set card color
  void setCardColor(CardColorModel color) {
    cardColor = color;

    // Generate new color variations
    cardColorVariations = cardColor.getColorVariations();

    // Select new random colors
    _selectRandomColors();

    // Update colors of existing particles
    for (final particle in particles) {
      if ((particle.type != ParticleType.emoji ||
              !particle.preserveEmojiColor) &&
          !particle.isTrail) {
        // Pilih warna acak dari 3 warna aktif baru
        particle.color =
            currentActiveColors[_random.nextInt(currentActiveColors.length)];
      }
    }
  }
}

// QuadTree for spatial partitioning (optimization)
class QuadTree {
  final Rect boundary;
  final int capacity;
  final List<Particle> particles = [];

  QuadTree? northWest;
  QuadTree? northEast;
  QuadTree? southWest;
  QuadTree? southEast;

  bool divided = false;

  QuadTree({
    required this.boundary,
    required this.capacity,
  });

  // Insert particle into quad tree
  bool insert(Particle particle) {
    // Check if particle is in bounds
    if (!boundary.contains(particle.position)) {
      return false;
    }

    // If there's space and not divided, add to this node
    if (particles.length < capacity && !divided) {
      particles.add(particle);
      return true;
    }

    // Otherwise, subdivide if needed and add to children
    if (!divided) {
      subdivide();
    }

    // Try inserting into each child
    if (northWest!.insert(particle)) return true;
    if (northEast!.insert(particle)) return true;
    if (southWest!.insert(particle)) return true;
    if (southEast!.insert(particle)) return true;

    // If we got here, something went wrong
    return false;
  }

  // Subdivide quad tree
  void subdivide() {
    final x = boundary.left;
    final y = boundary.top;
    final w = boundary.width / 2;
    final h = boundary.height / 2;

    final nw = Rect.fromLTWH(x, y, w, h);
    final ne = Rect.fromLTWH(x + w, y, w, h);
    final sw = Rect.fromLTWH(x, y + h, w, h);
    final se = Rect.fromLTWH(x + w, y + h, w, h);

    northWest = QuadTree(boundary: nw, capacity: capacity);
    northEast = QuadTree(boundary: ne, capacity: capacity);
    southWest = QuadTree(boundary: sw, capacity: capacity);
    southEast = QuadTree(boundary: se, capacity: capacity);

    divided = true;
  }

  // Query particles in an area
  List<Particle> query(Rect range, [List<Particle>? found]) {
    final result = found ?? <Particle>[];

    // Check if range doesn't intersect this node
    if (!boundary.overlaps(range)) {
      return result;
    }

    // Check particles in this node
    for (final particle in particles) {
      if (range.overlaps(particle.bounds)) {
        result.add(particle);
      }
    }

    // If divided, check children
    if (divided) {
      northWest!.query(range, result);
      northEast!.query(range, result);
      southWest!.query(range, result);
      southEast!.query(range, result);
    }

    return result;
  }

  // Clear the quad tree
  void clear() {
    particles.clear();

    if (divided) {
      northWest!.clear();
      northEast!.clear();
      southWest!.clear();
      southEast!.clear();
      divided = false;
      northWest = null;
      northEast = null;
      southWest = null;
      southEast = null;
    }
  }
}

// CustomPainter untuk rendering konfeti
class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  final Map<String, ui.Image> textureCache;

  ConfettiPainter({
    required this.particles,
    required this.textureCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect visibleRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Paint particles in batches for better performance
    List<Particle> emojiParticles = [];
    List<Particle> textParticles = [];
    List<Particle> circleParticles = [];

    // Sort into batches
    for (final particle in particles) {
      // Skip particles outside viewport (culling)
      if (!visibleRect.contains(Offset(particle.x, particle.y))) {
        continue;
      }

      if (particle.type == ParticleType.emoji) {
        emojiParticles.add(particle);
      } else if (particle.type == ParticleType.text) {
        textParticles.add(particle);
      } else if (particle.type == ParticleType.circle) {
        circleParticles.add(particle);
      }
    }

    // Draw all circle particles (most efficient, batch with same paint)
    if (circleParticles.isNotEmpty) {
      for (final particle in circleParticles) {
        final paint = Paint()
          ..color = particle.color.withOpacity(particle.alpha)
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(particle.x, particle.y);
        canvas.rotate(particle.rotation);

        // Draw circle
        canvas.drawCircle(
            Offset.zero, particle.size * particle.scale / 2, paint);

        canvas.restore();
      }
    }

    // Draw all emoji particles
    for (final particle in emojiParticles) {
      final image = textureCache[particle.content];
      if (image != null) {
        // Setup transformation
        canvas.save();
        canvas.translate(particle.x, particle.y);
        canvas.rotate(particle.rotation);
        canvas.scale(particle.scale);

        // Apply alpha if needed
        Paint paint = Paint();

        if (particle.preserveEmojiColor) {
          // Preserve emoji color, just apply alpha
          if (particle.alpha < 1.0) {
            paint.colorFilter = ColorFilter.mode(
              Colors.white.withOpacity(particle.alpha),
              BlendMode.modulate,
            );
          }
        } else {
          // Override emoji color
          paint.colorFilter = ColorFilter.mode(
            particle.color.withOpacity(particle.alpha),
            BlendMode.srcIn,
          );
        }

        // Draw image
        canvas.drawImage(
          image,
          Offset(-image.width / 2, -image.height / 2),
          paint,
        );

        canvas.restore();
      }
    }

    // Draw all text particles
    for (final particle in textParticles) {
      final image = textureCache[particle.content];
      if (image != null) {
        // Setup transformation
        canvas.save();
        canvas.translate(particle.x, particle.y);
        canvas.rotate(particle.rotation);
        canvas.scale(particle.scale);

        // Apply alpha and color
        final paint = Paint()
          ..colorFilter = ColorFilter.mode(
            particle.color.withOpacity(particle.alpha),
            BlendMode.srcIn,
          );

        // Draw image
        canvas.drawImage(
          image,
          Offset(-image.width / 2, -image.height / 2),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return true; // Always repaint when particles change
  }
}

// Custom confetti dialog yang minimalis
class CustomConfettiDialog extends StatefulWidget {
  final List<ParticleData> particles;
  final ConfettiAnimation defaultAnimationType;
  final VoidCallback? onButtonTap;
  final bool isAutoCloseDialog;
  final String? tapText;
  final TextStyle? tapTextStyle;
  final CardColorModel? cardColor;

  const CustomConfettiDialog({
    Key? key,
    required this.particles,
    this.defaultAnimationType = ConfettiAnimation.explode,
    this.onButtonTap,
    this.isAutoCloseDialog = false,
    this.tapText,
    this.tapTextStyle,
    this.cardColor,
  }) : super(key: key);

  @override
  _CustomConfettiDialogState createState() => _CustomConfettiDialogState();
}

class _CustomConfettiDialogState extends State<CustomConfettiDialog> {
  bool _showConfetti = true;
  late CardColorModel _cardColor;

  @override
  void initState() {
    super.initState();

    // Use provided card color or get random one
    _cardColor = widget.cardColor ?? CardColors.getRandom();

    if (widget.isAutoCloseDialog) {
      // Auto-close dialog after a set duration
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // Confetti overlay (full screen)
          if (_showConfetti)
            Positioned.fill(
              child: OptimizedConfetti(
                isPlaying: true,
                particles: widget.particles,
                cardColor: _cardColor,
                animation: widget.defaultAnimationType,
                duration: const Duration(seconds: 5),
                enableTapEffect: true,
                backgroundColor: Colors.transparent,
                shouldLoop: !widget.isAutoCloseDialog,
              ),
            ),

          // Simple text in the middle of the screen
          Positioned(
            bottom: screenSize.height * 0.3,
            left: 20,
            right: 20,
            child: Center(
              child: Text(
                widget.tapText ?? 'Tap anywhere on screen',
                style: widget.tapTextStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Optional close button
          if (!widget.isAutoCloseDialog)
            Positioned(
              top: 40 + MediaQuery.of(context).padding.top,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (widget.onButtonTap != null) {
                    widget.onButtonTap!();
                  }
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------
/// FUNGSI CONTOH UNTUK MENDAPATKAN LIST PARTIKEL RANDOM
/// ---------------------------------------------------------
List<ParticleData> getRandomParticles({CardColorModel? cardColor}) {
  final math.Random random = math.Random();
  final CardColorModel color = cardColor ?? CardColors.getRandom();

  return [
    // Emoji konfeti dengan warna asli dan trail
    ParticleData(
      type: ParticleType.emoji,
      count: 20,
      emoji: '🎉', // Akan diganti random saat runtime
      color: Colors.white, // Tidak digunakan karena preserveEmojiColor = true
      size: 30,
      speedParticle: 3.0,
      isLoopParticle: false,
      durationIntervalMs: 4000,
      preserveEmojiColor: true,
      leavesTrail: true, // Menggunakan partikel trail
      trailDecayMs: 300, // Trail hilang lebih cepat
    ),

    // Teks custom dengan warna kartu
    ParticleData(
      type: ParticleType.text,
      count: 10,
      text: 'WOW', // Akan diganti random saat runtime
      textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      color: Colors.white, // Akan diganti dengan warna kartu
      size: 30,
      speedParticle: 3.0,
      isLoopParticle: false,
      durationIntervalMs: 3000,
      useCardColor: true,
      leavesTrail: true, // Menggunakan partikel trail
      trailDecayMs: 300, // Trail hilang lebih cepat
    ),

    // Bulatan warna
    ParticleData(
      type: ParticleType.circle,
      count: 30,
      color: Colors.white, // Akan diganti dengan warna kartu
      size: 12,
      speedParticle: 2.5,
      isLoopParticle: false,
      durationIntervalMs: 3000,
      useCardColor: true,
      leavesTrail: true, // Menggunakan partikel trail
      trailDecayMs: 250, // Trail hilang lebih cepat
    ),
  ];
}

/// ---------------------------------------------------------
/// FUNGSI UTAMA UNTUK MENAMPILKAN DIALOG KONFETI
/// ---------------------------------------------------------
void showCustomConfettiDialog({
  required BuildContext context,
  VoidCallback? onButtonTap,
  bool isAutoCloseDialog = false,
  String? tapText,
  TextStyle? tapTextStyle,
  CardColorModel? cardColor,
  ConfettiAnimation? animation,
}) {
  final randomCardColor = cardColor ?? CardColors.getRandom();
  final randomParticles = getRandomParticles(cardColor: randomCardColor);
  final randomAnimationType = animation ??
      (math.Random().nextBool()
          ? ConfettiAnimation.rain
          : ConfettiAnimation.explode);

  // Menetapkan status bar menjadi transparan dan menutupi area app bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Mengaktifkan mode immersive untuk menutupi status bar dan navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (BuildContext dialogContext) {
      return Dialog(
        insetPadding: EdgeInsets.zero, // Menghilangkan padding default
        backgroundColor: Colors.transparent,
        child: CustomConfettiDialog(
          particles: randomParticles,
          defaultAnimationType: randomAnimationType,
          isAutoCloseDialog: isAutoCloseDialog,
          onButtonTap: onButtonTap,
          tapText: tapText,
          tapTextStyle: tapTextStyle,
          cardColor: randomCardColor,
        ),
      );
    },
  ).then((_) {
    // Kembalikan pengaturan UI seperti semula setelah dialog ditutup
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  });
}

// Contoh penggunaan dengan tombol
class ConfettiExampleScreen extends StatelessWidget {
  const ConfettiExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfeti Demo'),
        backgroundColor: CardColors.purplePrimary.card,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card dengan warna ungu gelap
            Card(
              color: CardColors.purpleDark.card,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showCustomConfettiDialog(
                    context: context,
                    cardColor: CardColors.purpleDark,
                    tapText: 'Ungu Gelap Celebration!',
                    animation: ConfettiAnimation.explode,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: const Text(
                    'Konfeti Ungu Gelap (Explode)',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card dengan warna biru
            Card(
              color: CardColors.blueSecondary.card,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showCustomConfettiDialog(
                    context: context,
                    cardColor: CardColors.blueSecondary,
                    tapText: 'Tap for more Blue Confetti!',
                    isAutoCloseDialog: false,
                    animation: ConfettiAnimation.rain,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: const Text(
                    'Konfeti Biru (Rain)',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card dengan warna pink-biru
            Card(
              color: CardColors.pinkBlue.card,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showCustomConfettiDialog(
                    context: context,
                    cardColor: CardColors.pinkBlue,
                    tapText: 'Pink Celebration!',
                    isAutoCloseDialog: true, // Auto-close setelah 5 detik
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: const Text(
                    'Konfeti Pink (Auto-close)',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card dengan warna random
            Card(
              color: Colors.grey[800],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showCustomConfettiDialog(
                    context: context, // Random color akan digunakan
                    tapText: 'Random Color Surprise!',
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: const Text(
                    'Konfeti Warna Random',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Confetti Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ConfettiExampleScreen(),
    );
  }
}
