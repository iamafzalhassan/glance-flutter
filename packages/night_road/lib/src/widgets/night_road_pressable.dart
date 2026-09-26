import 'package:flutter/widgets.dart';

import '../night_road_motion.dart';

class NightRoadPressable extends StatefulWidget {
  const NightRoadPressable({super.key, this.onPressed, required this.child});

  final VoidCallback? onPressed;

  final Widget child;

  @override
  State<NightRoadPressable> createState() => _NightRoadPressableState();
}

class _NightRoadPressableState extends State<NightRoadPressable> {
  static const double pressedOpacity = 0.4;

  bool _pressed = false;

  void _press(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final pressed = enabled && _pressed;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapCancel: () => _press(false),
        onTapDown: (_) => _press(enabled),
        onTapUp: (_) => _press(false),
        child: AnimatedOpacity(curve: NightRoadMotion.quickCurve, duration: NightRoadMotion.of(context, pressed ? NightRoadMotion.instant : NightRoadMotion.quick), opacity: pressed ? pressedOpacity : 1, child: widget.child),
      ),
    );
  }
}
