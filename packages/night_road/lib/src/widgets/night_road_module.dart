import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_radius.dart';
import '../night_road_spacing.dart';

class NightRoadModule extends StatelessWidget {
  const NightRoadModule({super.key, this.padding = const EdgeInsets.all(NightRoadSpacing.moduleInset), required this.child});

  final EdgeInsetsGeometry padding;

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(color: context.colors.bgPanel, shape: NightRoadRadius.panelShape),
    child: Padding(padding: padding, child: child),
  );
}
