// Wrap your existing IconButton with this widget.
// No state changes needed in the parent — it's fully self-contained.
//
// BEFORE:
//   IconButton(
//     onPressed: () => _scheduleReminder(context),
//     visualDensity: VisualDensity.compact,
//     icon: const Icon(Icons.alarm_add),
//     color: Theme.of(context).colorScheme.primary,
//     tooltip: "Schedule Reminder".tr(),
//   ),
//
// AFTER:
//   PulsingWrapper(
//     child: IconButton(
//       onPressed: () => _scheduleReminder(context),
//       visualDensity: VisualDensity.compact,
//       icon: const Icon(Icons.alarm_add),
//       color: Theme.of(context).colorScheme.primary,
//       tooltip: "Schedule Reminder".tr(),
//     ),
//   ),

import 'package:flutter/material.dart';

class PulsingWrapper extends StatefulWidget {
  final Widget child;
  const PulsingWrapper({required this.child});

  @override
  State<PulsingWrapper> createState() => PulsingWrapperState();
}

class PulsingWrapperState extends State<PulsingWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  bool _showPulse = true;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _opacity = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.repeat();

    // After 30 seconds, finish current cycle then hide
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      await _ctrl.forward(from: _ctrl.value); // finish current cycle
      if (!mounted) return;

      setState(() => _showPulse = false);
      _ctrl.stop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_showPulse)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}
