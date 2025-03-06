import 'package:easy_conffeti/easy_conffeti.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Confetti Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Confetti Examples'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Celebration Examples'),
              _buildExampleCard(
                context,
                title: 'Celebration Stars',
                description: 'Fireworks animation with star-shaped confetti',
                onTap: () => _showCelebrationConfetti(context),
              ),
              _buildExampleCard(
                context,
                title: 'Party Emoji Rain',
                description: 'Raining emoji particles',
                onTap: () => _showEmojiRainConfetti(context),
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Achievement Examples'),
              _buildExampleCard(
                context,
                title: 'Level Up',
                description: 'Golden fountain animation for level-ups',
                onTap: () => _showLevelUpConfetti(context),
              ),
              _buildExampleCard(
                context,
                title: 'Achievement Unlocked',
                description: 'Explosion of trophy emojis',
                onTap: () => _showAchievementConfetti(context),
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Result Examples'),
              _buildExampleCard(
                context,
                title: 'Success',
                description: 'Green confetti for success events',
                onTap: () => _showSuccessConfetti(context),
              ),
              _buildExampleCard(
                context,
                title: 'Try Again',
                description: 'Encouraging confetti for retry scenarios',
                onTap: () => _showTryAgainConfetti(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Celebration Examples
  void _showCelebrationConfetti(BuildContext context) async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: ConfettiType.celebration,
      confettiStyle: ConfettiStyle.star,
      animationStyle: AnimationConfetti.fireworks,
      colorTheme: ConfettiColorTheme.rainbow,
      message: "Celebration! 🎉",
      durationInSeconds: 3,
    );
  }

  void _showEmojiRainConfetti(BuildContext context) async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: ConfettiType.celebration,
      confettiStyle: ConfettiStyle.emoji,
      animationStyle: AnimationConfetti.rain,
      colorTheme: ConfettiColorTheme.pastel,
      message: "Party Time! 🥳",
      durationInSeconds: 3,
    );
  }

  // Achievement Examples
  void _showLevelUpConfetti(BuildContext context) async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: ConfettiType.levelUp,
      confettiStyle: ConfettiStyle.paper,
      animationStyle: AnimationConfetti.fountain,
      colorTheme: ConfettiColorTheme.gold,
      message: "Level Up! ⬆️",
      durationInSeconds: 3,
    );
  }

  void _showAchievementConfetti(BuildContext context) async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: ConfettiType.achievement,
      confettiStyle: ConfettiStyle.emoji,
      animationStyle: AnimationConfetti.explosion,
      colorTheme: ConfettiColorTheme.purple,
      message: "Achievement Unlocked! 🏆",
      durationInSeconds: 3,
    );
  }

  // Result Examples
  void _showSuccessConfetti(BuildContext context) async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: ConfettiType.success,
      confettiStyle: ConfettiStyle.paper,
      animationStyle: AnimationConfetti.explosion,
      colorTheme: ConfettiColorTheme.green,
      message: "Success! ✅",
      durationInSeconds: 3,
    );
  }

  void _showTryAgainConfetti(BuildContext context) async {
    await ConfettiHelper.showConfettiDialog(
      context: context,
      confettiType: ConfettiType.failed,
      confettiStyle: ConfettiStyle.star,
      animationStyle: AnimationConfetti.falling,
      colorTheme: ConfettiColorTheme.blue,
      message: "Almost there! Try again 💪",
      durationInSeconds: 3,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade800,
        ),
      ),
    );
  }
}
