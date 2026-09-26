import 'package:flutter/widgets.dart';

abstract final class NightRoadRadius {
  static const double card = 16;
  static const double panel = 24;
  static const double pill = 999;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius panelAll = BorderRadius.all(Radius.circular(panel));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  static const RoundedSuperellipseBorder cardShape = RoundedSuperellipseBorder(borderRadius: cardAll);
  static const RoundedSuperellipseBorder panelShape = RoundedSuperellipseBorder(borderRadius: panelAll);
  static const RoundedSuperellipseBorder pillShape = RoundedSuperellipseBorder(borderRadius: pillAll);
}
