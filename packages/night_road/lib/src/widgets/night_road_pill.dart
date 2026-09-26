import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_radius.dart';
import '../night_road_spacing.dart';
import '../night_road_type.dart';

class NightRoadPill extends StatelessWidget {
  const NightRoadPill({super.key, this.filled = false, required this.label, required this.color});

  final bool filled;

  final String label;

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: filled ? color : null,
      shape: NightRoadRadius.pillShape.copyWith(
        side: BorderSide(color: color, width: NightRoadSpacing.outline),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.lg, vertical: NightRoadSpacing.xs),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: NightRoadType.caption.copyWith(color: filled ? context.colors.bgBase : color),
      ),
    ),
  );
}
