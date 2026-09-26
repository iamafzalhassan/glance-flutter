import 'package:flutter/widgets.dart';

abstract final class NightRoadMotion {
  static const Curve bootCurve = Cubic(0.16, 1, 0.3, 1);
  static const Curve gentleCurve = Cubic(0.3, 0, 0, 1);
  static const Curve instantCurve = Curves.linear;
  static const Curve quickCurve = Cubic(0.2, 0, 0, 1);
  static const Curve standardCurve = Cubic(0.2, 0, 0, 1);

  static const Duration boot = Duration(milliseconds: 1200);
  static const Duration gentle = Duration(milliseconds: 600);
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 280);

  static Duration of(BuildContext context, Duration duration) => MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
