// color_picker_dialog.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-featured color picker dialog.
/// Usage:
///   final color = await showColorPickerDialog(context, initialColor: currentColor);
///   if (color != null) controller.setSeedColor(color);

Future<Color?> showColorPickerDialog(
  BuildContext context, {
  Color initialColor = const Color(0xFF6750A4),
  List<Color> recentColors = const [],
}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => ColorPickerDialog(
      initialColor: initialColor,
      recentColors: recentColors,
    ),
  );
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final List<Color> recentColors;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    this.recentColors = const [],
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // HSV values
  late double _hue; // 0 - 360
  late double _saturation; // 0 - 1
  late double _value; // 0 - 1
  late double _alpha; // 0 - 1

  late TextEditingController _hexController;
  bool _hexError = false;

  Color get _currentColor =>
      HSVColor.fromAHSV(_alpha, _hue, _saturation, _value).toColor();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _alpha = hsv.alpha;
    _hexController = TextEditingController(text: _colorToHex(_currentColor));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) =>
      '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  void _updateFromHex(String hex) {
    final clean = hex.replaceAll('#', '').replaceAll(' ', '');
    if (clean.length == 6) {
      final val = int.tryParse(clean, radix: 16);
      if (val != null) {
        final color = Color(0xFF000000 | val);
        final hsv = HSVColor.fromColor(color);
        setState(() {
          _hue = hsv.hue;
          _saturation = hsv.saturation;
          _value = hsv.value;
          _hexError = false;
        });
        return;
      }
    }
    setState(() => _hexError = clean.isNotEmpty);
  }

  void _syncHexFromHSV() {
    final hex = _colorToHex(_currentColor);
    if (_hexController.text.toUpperCase() != hex) {
      _hexController.text = hex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header / Preview ──────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 80,
              color: _currentColor,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Color Picker',
                    style: TextStyle(
                      color: _currentColor.computeLuminance() > 0.4
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Wheel'),
                Tab(text: 'Sliders'),
              ],
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Tab content ───────────────────────────────
                    SizedBox(
                      height: 280,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _WheelTab(
                            hue: _hue,
                            saturation: _saturation,
                            value: _value,
                            onChanged: (h, s, v) {
                              setState(() {
                                _hue = h;
                                _saturation = s;
                                _value = v;
                              });
                              _syncHexFromHSV();
                            },
                          ),
                          _SlidersTab(
                            hue: _hue,
                            saturation: _saturation,
                            value: _value,
                            onChanged: (h, s, v) {
                              setState(() {
                                _hue = h;
                                _saturation = s;
                                _value = v;
                              });
                              _syncHexFromHSV();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Alpha slider ──────────────────────────────
                    _AlphaSlider(
                      alpha: _alpha,
                      color: _currentColor,
                      onChanged: (a) {
                        setState(() => _alpha = a);
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── HEX input ─────────────────────────────────
                    TextField(
                      controller: _hexController,
                      decoration: InputDecoration(
                        labelText: 'HEX',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _currentColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: scheme.outline.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        errorText: _hexError ? 'Invalid hex' : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _colorToHex(_currentColor)),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      inputFormatters: [
                        _HexInputFormatter(),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onChanged: _updateFromHex,
                    ),

                    const SizedBox(height: 16),

                    // ── Recent Colors ─────────────────────────────
                    if (widget.recentColors.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.recentColors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final c = widget.recentColors[i];
                            final isSelected = c.value == _currentColor.value;
                            return GestureDetector(
                              onTap: () {
                                final hsv = HSVColor.fromColor(c);
                                setState(() {
                                  _hue = hsv.hue;
                                  _saturation = hsv.saturation;
                                  _value = hsv.value;
                                  _alpha = hsv.alpha;
                                });
                                _syncHexFromHSV();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: scheme.primary,
                                          width: 2.5,
                                        )
                                      : Border.all(
                                          color: scheme.outline.withOpacity(
                                            0.3,
                                          ),
                                          width: 1,
                                        ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.withOpacity(0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: c.computeLuminance() > 0.4
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),

            // ── Actions ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _currentColor),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WHEEL TAB
// ─────────────────────────────────────────────────────────────
class _WheelTab extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double h, double s, double v) onChanged;

  const _WheelTab({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _ColorWheel(
            hue: hue,
            saturation: saturation,
            onChanged: (h, s) => onChanged(h, s, value),
          ),
        ),
        const SizedBox(height: 12),
        // Brightness slider under wheel
        Row(
          children: [
            const Icon(Icons.brightness_low, size: 16),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 12,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: value,
                  onChanged: (v) => onChanged(hue, saturation, v),
                ),
              ),
            ),
            const Icon(Icons.brightness_high, size: 16),
          ],
        ),
      ],
    );
  }
}

class _ColorWheel extends StatefulWidget {
  final double hue;
  final double saturation;
  final void Function(double hue, double saturation) onChanged;

  const _ColorWheel({
    required this.hue,
    required this.saturation,
    required this.onChanged,
  });

  @override
  State<_ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<_ColorWheel> {
  void _handleDrag(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final delta = localPos - center;
    final distance = delta.distance.clamp(0, radius);
    final angle = (math.atan2(delta.dy, delta.dx) * 180 / math.pi + 360) % 360;
    widget.onChanged(angle, distance / radius);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) =>
          _handleDrag(d.localPosition, context.size ?? const Size(200, 200)),
      onPanUpdate: (d) =>
          _handleDrag(d.localPosition, context.size ?? const Size(200, 200)),
      onTapDown: (d) =>
          _handleDrag(d.localPosition, context.size ?? const Size(200, 200)),
      child: CustomPaint(
        painter: _WheelPainter(hue: widget.hue, saturation: widget.saturation),
        child: const SizedBox(width: 200, height: 200),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final double hue;
  final double saturation;

  _WheelPainter({required this.hue, required this.saturation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw hue wheel
    for (int i = 0; i < 360; i++) {
      final paint = Paint()
        ..shader = SweepGradient(
          colors: List.generate(360, (deg) {
            return HSVColor.fromAHSV(1, deg.toDouble(), 1, 1).toColor();
          }),
          startAngle: 0,
          endAngle: 2 * math.pi,
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
      break;
    }

    // White radial overlay (saturation)
    final whitePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0)],
        radius: 1,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, whitePaint);

    // Thumb
    final angle = hue * math.pi / 180;
    final thumbPos =
        center +
        Offset(
          math.cos(angle) * saturation * radius,
          math.sin(angle) * saturation * radius,
        );

    final thumbColor = HSVColor.fromAHSV(1, hue, saturation, 1).toColor();
    canvas.drawCircle(thumbPos, 12, Paint()..color = thumbColor);
    canvas.drawCircle(
      thumbPos,
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.hue != hue || old.saturation != saturation;
}

// ─────────────────────────────────────────────────────────────
// SLIDERS TAB
// ─────────────────────────────────────────────────────────────
class _SlidersTab extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double h, double s, double v) onChanged;

  const _SlidersTab({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  Widget _label(String text) => SizedBox(
    width: 28,
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final r = HSVColor.fromAHSV(1, hue, saturation, value).toColor().red;
    final g = HSVColor.fromAHSV(1, hue, saturation, value).toColor().green;
    final b = HSVColor.fromAHSV(1, hue, saturation, value).toColor().blue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hue
        Row(
          children: [
            _label('H'),
            Expanded(
              child: _GradientSlider(
                value: hue / 360,
                gradient: LinearGradient(
                  colors: List.generate(
                    7,
                    (i) => HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor(),
                  ),
                ),
                onChanged: (v) => onChanged(v * 360, saturation, value),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${hue.round()}°',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Saturation
        Row(
          children: [
            _label('S'),
            Expanded(
              child: _GradientSlider(
                value: saturation,
                gradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(1, hue, 0, value).toColor(),
                    HSVColor.fromAHSV(1, hue, 1, value).toColor(),
                  ],
                ),
                onChanged: (v) => onChanged(hue, v, value),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${(saturation * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Value/Brightness
        Row(
          children: [
            _label('V'),
            Expanded(
              child: _GradientSlider(
                value: value,
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    HSVColor.fromAHSV(1, hue, saturation, 1).toColor(),
                  ],
                ),
                onChanged: (v) => onChanged(hue, saturation, v),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${(value * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const Divider(height: 28),
        // RGB display (read-only info)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _RgbChip(label: 'R', value: r, color: Colors.red),
            _RgbChip(label: 'G', value: g, color: Colors.green),
            _RgbChip(label: 'B', value: b, color: Colors.blue),
          ],
        ),
      ],
    );
  }
}

class _RgbChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _RgbChip({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text('$value', style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// A slider drawn over a gradient track
class _GradientSlider extends StatelessWidget {
  final double value;
  final LinearGradient gradient;
  final ValueChanged<double> onChanged;

  const _GradientSlider({
    required this.value,
    required this.gradient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 14,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        trackShape: _GradientTrackShape(gradient),
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: Colors.transparent,
        thumbColor: HSVColor.fromAHSV(
          1,
          value * (gradient.colors.length == 7 ? 360 : 1),
          1,
          1,
        ).toColor(),
      ),
      child: Slider(value: value.clamp(0, 1), onChanged: onChanged),
    );
  }
}

class _GradientTrackShape extends SliderTrackShape {
  final LinearGradient gradient;
  const _GradientTrackShape(this.gradient);

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(7));
    final paint = Paint()..shader = gradient.createShader(rect);
    context.canvas.drawRRect(rrect, paint);
  }
}

// ─────────────────────────────────────────────────────────────
// ALPHA SLIDER
// ─────────────────────────────────────────────────────────────
class _AlphaSlider extends StatelessWidget {
  final double alpha;
  final Color color;
  final ValueChanged<double> onChanged;

  const _AlphaSlider({
    required this.alpha,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 28,
          child: Text(
            'A',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 14,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackShape: _GradientTrackShape(
                LinearGradient(colors: [color.withOpacity(0), color]),
              ),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(value: alpha, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(alpha * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HEX INPUT FORMATTER
// ─────────────────────────────────────────────────────────────
class _HexInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase();
    if (!text.startsWith('#')) text = '#$text';
    final clean = '#' + text.substring(1).replaceAll(RegExp(r'[^0-9A-F]'), '');
    return newValue.copyWith(
      text: clean,
      selection: TextSelection.collapsed(offset: clean.length),
    );
  }
}
