import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  RamadanZeena — Permanent decorative hanging مoons widget
///
///  Drop this anywhere in your widget tree as an overlay or header.
///  Each "zeena" is a string with a crescent moon (+ optional star)
///  hanging at different lengths, gently swaying.
/// ═══════════════════════════════════════════════════════════════

// ── Data model for one hanging decoration ──────────────────────
class ZeenaItem {
  final double xFraction; // 0.0–1.0 horizontal position
  final double ropeLength; // pixels
  final Color color;
  final bool hasStar;
  final double moonRadius;
  final double swayDelay; // stagger the animation

  const ZeenaItem({
    required this.xFraction,
    required this.ropeLength,
    required this.color,
    required this.hasStar,
    required this.moonRadius,
    required this.swayDelay,
  });
}

// ── Preset zeena configurations ────────────────────────────────
const List<ZeenaItem> _defaultZeenas = [
  ZeenaItem(
    xFraction: 0.04,
    ropeLength: 90,
    color: Color(0xFFFFD700),
    hasStar: false,
    moonRadius: 14,
    swayDelay: 0.0,
  ),
  ZeenaItem(
    xFraction: 0.14,
    ropeLength: 55,
    color: Color(0xFF00CED1),
    hasStar: true,
    moonRadius: 11,
    swayDelay: 0.3,
  ),
  ZeenaItem(
    xFraction: 0.23,
    ropeLength: 80,
    color: Color(0xFFFF69B4),
    hasStar: false,
    moonRadius: 16,
    swayDelay: 0.6,
  ),
  ZeenaItem(
    xFraction: 0.33,
    ropeLength: 70,
    color: Color(0xFF98FB98),
    hasStar: true,
    moonRadius: 12,
    swayDelay: 0.9,
  ),
  ZeenaItem(
    xFraction: 0.43,
    ropeLength: 75,
    color: Color(0xFFFFD700),
    hasStar: false,
    moonRadius: 18,
    swayDelay: 0.2,
  ),
  ZeenaItem(
    xFraction: 0.53,
    ropeLength: 60,
    color: Color(0xFFE0BBFF),
    hasStar: true,
    moonRadius: 13,
    swayDelay: 0.5,
  ),
  ZeenaItem(
    xFraction: 0.63,
    ropeLength: 65,
    color: Color(0xFFFFA500),
    hasStar: false,
    moonRadius: 15,
    swayDelay: 0.8,
  ),
  ZeenaItem(
    xFraction: 0.72,
    ropeLength: 80,
    color: Color(0xFF87CEEB),
    hasStar: true,
    moonRadius: 11,
    swayDelay: 0.1,
  ),
  ZeenaItem(
    xFraction: 0.81,
    ropeLength: 50,
    color: Color(0xFFFF69B4),
    hasStar: false,
    moonRadius: 14,
    swayDelay: 0.4,
  ),
  ZeenaItem(
    xFraction: 0.90,
    ropeLength: 75,
    color: Color(0xFFFFD700),
    hasStar: true,
    moonRadius: 17,
    swayDelay: 0.7,
  ),
  ZeenaItem(
    xFraction: 0.97,
    ropeLength: 68,
    color: Color(0xFF98FB98),
    hasStar: false,
    moonRadius: 12,
    swayDelay: 0.2,
  ),
];

/// ── Public Widget ──────────────────────────────────────────────
///
/// Usage:
///   Stack(
///     children: [
///       YourPageContent(),
///       RamadanZeena(),          // overlays at top
///     ],
///   )
///
/// Or as a header/decoration inside a Column.
class RamadanZeena extends StatefulWidget {
  /// Override to provide your own zeena items
  final List<ZeenaItem>? items;

  /// Height of the widget (should be >= longest rope + moon)
  final double height;

  /// Whether the moons sway
  final bool animate;

  final bool isWillBeHidden;

  final bool isWithRope;
  const RamadanZeena({
    super.key,
    this.items,
    this.height = 160,
    this.animate = true,
    this.isWithRope = true,
    this.isWillBeHidden = true,
  });

  @override
  State<RamadanZeena> createState() => _RamadanZeenaState();
}

class _RamadanZeenaState extends State<RamadanZeena>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _isHiding = false; // triggers animation
  bool _removed = false; // actually removes widget
  bool _isDimmed = false;
  @override
  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    if (!widget.animate || widget.isWillBeHidden) {
      Future.delayed(const Duration(seconds: 6), () {
        if (!mounted) return;

        _ctrl.stop();

        setState(() {
          _isDimmed = true; // trigger opacity reduction
        });
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items ?? _defaultZeenas;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      opacity: _isDimmed ? 0.3 : 1.0,
      child: RepaintBoundary(
        child: SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  widget.isWithRope
                      ? Positioned(
                          top: 2,
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: Size(w, 6),
                            painter: _RopeLinePainter(),
                          ),
                        )
                      : const SizedBox.shrink(),
                  ...items.map((item) {
                    final x = w * item.xFraction;
                    return _SwayingZeena(
                      controller: _ctrl,
                      item: item,
                      x: x,
                      animate: widget.animate && !_isDimmed,
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Individual swaying zeena ────────────────────────────────────
class _SwayingZeena extends StatelessWidget {
  final AnimationController controller;
  final ZeenaItem item;
  final double x;
  final bool animate;

  const _SwayingZeena({
    required this.controller,
    required this.item,
    required this.x,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final phase = (controller.value + item.swayDelay) % 1.0;
          final sway = sin(phase * 2 * pi) * 6.0;
          final angle = sway * (pi / 180);

          return Positioned(
            left: x - item.moonRadius - 5,
            top: 0,
            child: RepaintBoundary(
              // ✅ isolate repaint
              child: CustomPaint(
                size: Size(
                  item.moonRadius * 2 + 10,
                  item.ropeLength + item.moonRadius * 2 + 8,
                ),
                painter: _ZeenaPainter(item: item, swayAngle: angle),
              ),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        // Each item sways at slightly different phase
        final phase = (controller.value + item.swayDelay) % 1.0;
        final sway = sin(phase * 2 * pi) * 6.0; // max ±6 degrees
        final angle = sway * (pi / 180);

        return Positioned(
          left: x - item.moonRadius - 5,
          top: 0,
          child: CustomPaint(
            size: Size(
              item.moonRadius * 2 + 10,
              item.ropeLength + item.moonRadius * 2 + 8,
            ),
            painter: _ZeenaPainter(item: item, swayAngle: angle),
          ),
        );
      },
    );
  }
}

// ── Painter: one rope + crescent + optional star ────────────────
class _ZeenaPainter extends CustomPainter {
  final ZeenaItem item;
  final double swayAngle;

  const _ZeenaPainter({required this.item, required this.swayAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final r = item.moonRadius;

    // Pivot at top-center, rotate the whole hanging piece
    canvas.save();
    canvas.translate(cx, 0);
    canvas.rotate(swayAngle);
    canvas.translate(-cx, 0);

    // ── Rope ──
    final ropePaint = Paint()
      ..color = item.color.withOpacity(0.6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Slightly wavy rope using a quadratic bezier
    final ropeStart = Offset(cx, 0);
    final ropeEnd = Offset(cx, item.ropeLength);
    final ropeCtrl = Offset(cx + sin(swayAngle * 3) * 4, item.ropeLength * 0.5);

    final ropePath = Path()
      ..moveTo(ropeStart.dx, ropeStart.dy)
      ..quadraticBezierTo(ropeCtrl.dx, ropeCtrl.dy, ropeEnd.dx, ropeEnd.dy);
    canvas.drawPath(ropePath, ropePaint);

    // ── Crescent Moon ──
    final moonCenter = Offset(cx, item.ropeLength + r);
    _drawCrescent(canvas, moonCenter, r, item.color);

    // ── Optional tiny star ──
    if (item.hasStar) {
      final starCenter = Offset(cx + r * 1.15, item.ropeLength + r * 0.2);
      _drawStar(canvas, starCenter, r * 0.28, item.color);
    }

    // ── Subtle glow ──
    final glowPaint = Paint()
      ..color = item.color.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, item.ropeLength + r), r * 1.3, glowPaint);

    canvas.restore();
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius, Color color) {
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final innerCenter = Offset(
      center.dx + radius * 0.38,
      center.dy - radius * 0.05,
    );
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: radius * 0.80));

    final crescent = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    // Fill
    canvas.drawPath(crescent, Paint()..color = color);
    // Shine highlight
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.8,
          colors: [Colors.white.withOpacity(0.45), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    const points = 4;
    final path = Path();
    final step = (2 * pi) / points;
    final half = step / 2;
    path.moveTo(center.dx + r * cos(0), center.dy + r * sin(0));
    for (int i = 0; i < points; i++) {
      final a = i * step;
      path.lineTo(center.dx + r * cos(a), center.dy + r * sin(a));
      path.lineTo(
        center.dx + r * 0.4 * cos(a + half),
        center.dy + r * 0.4 * sin(a + half),
      );
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ZeenaPainter old) => old.swayAngle != swayAngle;
}

// ── Horizontal rope line at the very top ───────────────────────
class _RopeLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Slightly catenary-curved rope
    final path = Path();
    path.moveTo(0, 3);
    final segments = 20;
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = t * size.width;
      // Catenary-ish droop
      final droop = sin(t * pi) * 5;
      if (i == 0) {
        path.moveTo(x, droop);
      } else {
        path.lineTo(x, droop);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
