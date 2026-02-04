import 'dart:math' as math;

import 'package:ella_lyaabdoon/core/services/strike_service.dart';
import 'package:flutter/material.dart';

class StreakAnimationWidget extends StatefulWidget {
  final int streakCount;
  final VoidCallback? onTap;

  const StreakAnimationWidget({
    super.key,
    required this.streakCount,
    this.onTap,
  });

  @override
  State<StreakAnimationWidget> createState() => _StreakAnimationWidgetState();
}

class _StreakAnimationWidgetState extends State<StreakAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation (continuous)
    _rotationController = AnimationController(
      duration: _getRotationDuration(),
      vsync: this,
    )..repeat();

    // Pulse animation (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale animation (for tap)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  Duration _getRotationDuration() {
    // Faster rotation for higher streaks
    if (widget.streakCount >= 30) return const Duration(seconds: 2);
    if (widget.streakCount >= 14) return const Duration(seconds: 3);
    if (widget.streakCount >= 7) return const Duration(seconds: 4);
    if (widget.streakCount >= 3) return const Duration(seconds: 5);
    return const Duration(seconds: 6);
  }

  bool _shouldShowShimmer() {
    return widget.streakCount >= 30;
  }

  bool _shouldShowParticles() {
    return widget.streakCount >= 30;
  }

  void _handleTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = StrikeService.getStrikeColor(widget.streakCount);

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 60,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating flare/glow effect
              if (widget.streakCount > 0)
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(50, 50),
                        painter: FlarePainter(
                          color: color.withOpacity(0.3),
                          streakCount: widget.streakCount,
                        ),
                      ),
                    );
                  },
                ),

              // Shimmer effect for high streaks
              if (_shouldShowShimmer())
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(0.2 * _pulseAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Particles for epic streaks
              if (_shouldShowParticles())
                ...List.generate(6, (index) {
                  return _ParticleWidget(
                    index: index,
                    color: color,
                    controller: _pulseController,
                  );
                }),

              // Main flame icon with pulse
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Icon(
                      Icons.local_fire_department,
                      color: color,
                      size: 24,
                    ),
                  );
                },
              ),

              // Streak count
              Positioned(
                right: 0,
                child: Text(
                  widget.streakCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                    shadows: [
                      Shadow(blurRadius: 4, color: color.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for flare/glow effect
class FlarePainter extends CustomPainter {
  final Color color;
  final int streakCount;

  FlarePainter({required this.color, required this.streakCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final center = Offset(size.width / 2, size.height / 2);
    final rayCount = streakCount >= 30
        ? 8
        : streakCount >= 14
        ? 6
        : 4;
    final rayLength = size.width / 2;
    final rayWidth = streakCount >= 30 ? 3.0 : 2.0;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount);
      final startX = center.dx + math.cos(angle) * (rayLength * 0.3);
      final startY = center.dy + math.sin(angle) * (rayLength * 0.3);
      final endX = center.dx + math.cos(angle) * rayLength;
      final endY = center.dy + math.sin(angle) * rayLength;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = rayWidth,
      );
    }
  }

  @override
  bool shouldRepaint(FlarePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.streakCount != streakCount;
  }
}

// Particle widget for epic streaks
class _ParticleWidget extends StatelessWidget {
  final int index;
  final Color color;
  final AnimationController controller;

  const _ParticleWidget({
    required this.index,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final angle = (index * 2 * math.pi / 6);
    final distance = 20.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = distance * controller.value;
        return Transform.translate(
          offset: Offset(math.cos(angle) * offset, math.sin(angle) * offset),
          child: Opacity(
            opacity: 1.0 - controller.value,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
