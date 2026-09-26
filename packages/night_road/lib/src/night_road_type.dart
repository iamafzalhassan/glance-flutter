import 'package:flutter/painting.dart';

abstract final class NightRoadType {
  static const String fontFamily = 'SFProDisplay';
  static const String package = 'night_road';

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle body = TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w400, height: 1.2, package: package);
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontFeatures: tabular, fontSize: 16, fontWeight: FontWeight.w500, height: 1.2, package: package);
  static const TextStyle numLarge = TextStyle(fontFamily: fontFamily, fontFeatures: tabular, fontSize: 48, fontWeight: FontWeight.w500, height: 1, package: package);
  static const TextStyle numMedium = TextStyle(fontFamily: fontFamily, fontFeatures: tabular, fontSize: 32, fontWeight: FontWeight.w400, height: 1, package: package);
  static const TextStyle numSpeed = TextStyle(fontFamily: fontFamily, fontFeatures: tabular, fontSize: 168, fontWeight: FontWeight.w500, height: 1, letterSpacing: -4, package: package);
  static const TextStyle title = TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, height: 1.2, package: package);
  static const TextStyle toolHeading = TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w700, height: 1.2, package: package);
  static const TextStyle toolLabel = TextStyle(fontFamily: fontFamily, fontFeatures: tabular, fontSize: 13, fontWeight: FontWeight.w400, height: 1.2, package: package);
}
