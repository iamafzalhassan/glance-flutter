import 'dart:math';

final class BrightnessPolicy {
  static const BrightnessPolicy standard = BrightnessPolicy();

  final double darkLux;
  final double heatCap;
  final double parkedLevel;
  final double ridingFloor;
  final double sunLux;

  const BrightnessPolicy({this.darkLux = 10, this.heatCap = 0.7, this.parkedLevel = 0.05, this.ridingFloor = 0.35, this.sunLux = 20000});

  double ridingLevel({required bool hot, required double lux}) {
    final position = (log(lux.clamp(darkLux, sunLux)) - log(darkLux)) / (log(sunLux) - log(darkLux));
    final level = ridingFloor + (1 - ridingFloor) * position;
    return hot ? min(level, heatCap) : level;
  }
}
