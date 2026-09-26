import 'package:flutter/widgets.dart';

import 'night_road_colors.dart';
import 'night_road_theme.dart';

extension NightRoadContext on BuildContext {
  NightRoadColors get colors => NightRoadTheme.colorsOf(this);
}
