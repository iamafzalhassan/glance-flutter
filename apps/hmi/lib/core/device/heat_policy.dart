import 'device_heat.dart';

final class HeatPolicy {
  static const HeatPolicy standard = HeatPolicy();

  final double coolBelowCelsius;
  final double hotAboveCelsius;

  final int hotThermalStatus;

  const HeatPolicy({this.coolBelowCelsius = 41, this.hotAboveCelsius = 45, this.hotThermalStatus = 3});

  bool isHot(DeviceHeat heat, {required bool wasHot}) {
    if (heat.thermalStatus >= hotThermalStatus) return true;
    final celsius = heat.batteryCelsius;
    if (celsius == null) return false;
    return wasHot ? celsius >= coolBelowCelsius : celsius >= hotAboveCelsius;
  }
}
