import 'package:flutter/widgets.dart';
import 'package:night_road/night_road.dart';

class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.size, required this.child});

  final Size size;

  final Widget child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: size.width / size.height,
    child: DecoratedBox(
      decoration: ShapeDecoration(
        color: context.colors.bgRaised,
        shape: NightRoadRadius.panelShape.copyWith(
          side: BorderSide(color: context.colors.lineSubtle, width: NightRoadSpacing.outline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NightRoadSpacing.md),
        child: ClipRSuperellipse(borderRadius: NightRoadRadius.cardAll, child: child),
      ),
    ),
  );
}
