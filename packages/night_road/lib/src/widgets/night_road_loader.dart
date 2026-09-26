import 'package:flutter/cupertino.dart';

import '../night_road_context.dart';
import '../night_road_spacing.dart';

class NightRoadLoader extends StatelessWidget {
  const NightRoadLoader({super.key, this.color});

  static const double _radius = NightRoadSpacing.loader / 2;

  final Color? color;

  @override
  Widget build(BuildContext context) => CupertinoActivityIndicator(color: color ?? context.colors.textMuted, radius: _radius);
}
