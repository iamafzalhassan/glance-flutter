import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_spacing.dart';
import 'night_road_pressable.dart';

class NightRoadRoundButton extends StatelessWidget {
  const NightRoadRoundButton({super.key, this.size = NightRoadSpacing.touchRiding, required this.icon, this.onPressed});

  final double size;

  final IconData icon;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return NightRoadPressable(
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: colors.bgRaised, shape: const CircleBorder()),
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, color: onPressed == null ? colors.textMuted : colors.textPrimary, size: NightRoadSpacing.icon),
        ),
      ),
    );
  }
}
