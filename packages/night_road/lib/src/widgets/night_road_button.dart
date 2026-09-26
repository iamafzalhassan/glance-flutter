import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_radius.dart';
import '../night_road_spacing.dart';
import '../night_road_type.dart';
import 'night_road_pressable.dart';

class NightRoadButton extends StatelessWidget {
  const NightRoadButton({super.key, required this.label, required this.color, this.foreground, this.onPressed});

  final String label;

  final Color color;

  final Color? foreground;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => NightRoadPressable(
    onPressed: onPressed,
    child: DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: NightRoadRadius.pillShape),
      child: SizedBox(
        height: NightRoadSpacing.touchRiding,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.xl),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NightRoadType.title.copyWith(color: foreground ?? context.colors.bgBase),
            ),
          ),
        ),
      ),
    ),
  );
}
