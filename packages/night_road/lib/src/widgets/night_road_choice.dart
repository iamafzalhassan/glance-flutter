import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_motion.dart';
import '../night_road_radius.dart';
import '../night_road_spacing.dart';
import '../night_road_type.dart';
import 'night_road_pressable.dart';

class NightRoadChoice extends StatelessWidget {
  const NightRoadChoice({super.key, required this.selected, required this.label, required this.onSelected});

  final bool selected;

  final String label;

  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return NightRoadPressable(
      onPressed: onSelected,
      child: AnimatedContainer(
        alignment: Alignment.center,
        curve: NightRoadMotion.quickCurve,
        decoration: ShapeDecoration(color: selected ? colors.textPrimary : colors.bgRaised, shape: NightRoadRadius.pillShape),
        duration: NightRoadMotion.of(context, NightRoadMotion.quick),
        height: NightRoadSpacing.touch,
        padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.xl),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: NightRoadType.body.copyWith(color: selected ? colors.bgBase : colors.textPrimary),
        ),
      ),
    );
  }
}
