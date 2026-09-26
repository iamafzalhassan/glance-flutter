import 'package:flutter/material.dart';

import 'night_road_colors.dart';
import 'night_road_type.dart';

abstract final class NightRoadTheme {
  static final ThemeData day = _build(Brightness.light, NightRoadColors.day);
  static final ThemeData night = _build(Brightness.dark, NightRoadColors.night);

  static NightRoadColors colorsOf(BuildContext context) => Theme.of(context).extension<NightRoadColors>() ?? NightRoadColors.night;

  static ThemeData _build(Brightness brightness, NightRoadColors colors) => ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      error: colors.stateDanger,
      onError: colors.bgBase,
      onPrimary: colors.textPrimary,
      onSecondary: colors.bgBase,
      onSurface: colors.textPrimary,
      primary: colors.accentNav,
      secondary: colors.stateEco,
      surface: colors.bgPanel,
    ),
    extensions: [colors],
    fontFamily: NightRoadType.fontFamily,
    package: NightRoadType.package,
    scaffoldBackgroundColor: colors.bgBase,
    splashFactory: NoSplash.splashFactory,
  );
}
