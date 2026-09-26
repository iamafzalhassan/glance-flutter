import '../providers/display_providers.dart';

final class ThemePolicy {
  static const ThemePolicy standard = ThemePolicy();

  final double dayAboveLux;
  final double nightBelowLux;

  const ThemePolicy({this.dayAboveLux = 1500, this.nightBelowLux = 400});

  DisplayTheme next(double lux, DisplayTheme current) {
    if (lux >= dayAboveLux) return DisplayTheme.day;
    if (lux <= nightBelowLux) return DisplayTheme.night;
    return current;
  }
}
