import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/services/streak_service.dart';
import 'package:flutter/material.dart';

class StreakConfettiController {
  late ConfettiController _confettiController;
  BuildContext? _context;

  StreakConfettiController() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 6),
    );
  }

  void initialize(BuildContext context) {
    _context = context;
  }

  void dispose() {
    _confettiController.dispose();
  }

  ConfettiController get controller => _confettiController;

  /// Trigger confetti based on milestone
  void celebrateMilestone(Map<String, dynamic>? milestoneData) {
    if (milestoneData == null || !milestoneData['shouldCelebrate']) return;
    if (_context == null || !_context!.mounted) return;

    final milestone = milestoneData['milestone'] as int;
    final milestoneName = milestoneData['name'] as String;

    debugPrint('🎉 Celebrating milestone: $milestone days');

    // Trigger confetti
    _confettiController.play();

    // Show congratulations dialog
    _showCongratulationsDialog(milestone, milestoneName);
  }

  void _showCongratulationsDialog(int milestone, String milestoneName) {
    if (_context == null || !_context!.mounted) return;

    final color = StreakService.getStreakColor(milestone);

    showDialog(
      context: _context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: value * 2 * pi,
                      child: Icon(Icons.emoji_events, size: 80, color: color),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Congratulations text
              Text(
                'congratulations'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),

              // Milestone achieved
              Text(
                'milestone_achieved'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Milestone badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: color, size: 32),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestoneName.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        ),
                        Text(
                          '$milestone ${'days'.tr()}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: color.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Keep going message
              Text(
                'keep_going'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Close button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('ok'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get confetti widget to overlay on screen
  Widget getConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        particleDrag: 0.05,
        emissionFrequency: 0.1, // Increased from 0.05
        numberOfParticles: _getParticleCount(),
        gravity: 0.2, // Increased gravity slightly for better fall
        shouldLoop: false,
        colors: _getConfettiColors(),
        createParticlePath: _createCustomPath,
      ),
    );
  }

  int _getParticleCount() {
    // More particles for higher milestones
    final currentStreak = StreakService.getStreakCount();
    if (currentStreak >= 365) return 300;
    if (currentStreak >= 180) return 250;
    if (currentStreak >= 90) return 200;
    if (currentStreak >= 60) return 200;
    if (currentStreak >= 30) return 200;
    if (currentStreak >= 14) return 150;
    if (currentStreak >= 7) return 100;
    if (currentStreak >= 7) return 100;
    if (currentStreak >= 3) return 50;
    return 50; // Minimum 50 particles (was 30)
  }

  List<Color> _getConfettiColors() {
    final currentStreak = StreakService.getStreakCount();

    // Rainbow colors for epic streaks
    if (currentStreak >= 60) {
      return [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple,
        Colors.pink,
      ];
    }

    // Purple + amber for platinum
    if (currentStreak >= 30) {
      return [Colors.purple, Colors.deepPurple, Colors.amber, Colors.orange];
    }

    // Amber + orange for gold
    if (currentStreak >= 14) {
      return [Colors.amber, Colors.orange, Colors.deepOrange];
    }

    // Orange + deep orange for silver
    if (currentStreak >= 7) {
      return [Colors.orange, Colors.deepOrange];
    }

    // Orange/red for bronze
    return [const Color(0xffF45D51), Colors.orange];
  }

  Path _createCustomPath(Size size) {
    final path = Path();
    final random = Random();

    // Mix of shapes based on streak
    final currentStreak = StreakService.getStreakCount();

    if (currentStreak >= 30 && random.nextBool()) {
      // Star shape for high streaks
      _drawStar(path, size);
    } else if (currentStreak >= 14 && random.nextBool()) {
      // Heart shape for medium streaks
      _drawHeart(path, size);
    } else {
      // Default rectangle
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    return path;
  }

  void _drawStar(Path path, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;
    const numPoints = 5;

    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / numPoints) - pi / 2;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
  }

  void _drawHeart(Path path, Size size) {
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height / 4);
    path.cubicTo(width / 2, height / 5, width / 3, 0, width / 6, height / 5);
    path.cubicTo(0, height / 3, 0, height / 2, width / 6, height * 2 / 3);
    path.cubicTo(
      width / 4,
      height * 5 / 6,
      width / 2,
      height,
      width / 2,
      height,
    );
    path.cubicTo(
      width / 2,
      height,
      width * 3 / 4,
      height * 5 / 6,
      width * 5 / 6,
      height * 2 / 3,
    );
    path.cubicTo(
      width,
      height / 2,
      width,
      height / 3,
      width * 5 / 6,
      height / 5,
    );
    path.cubicTo(
      width * 2 / 3,
      0,
      width / 2,
      height / 5,
      width / 2,
      height / 4,
    );
    path.close();
  }
}
