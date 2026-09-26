import 'dart:math';

import 'package:glance_protocol/glance_protocol.dart';

import 'stop_start_mode.dart';

final class SimulatedBike {
  static const double accelerationKmhPerSecond = 9;
  static const double autoStopArmKmh = 10;
  static const double brakingKmhPerSecond = 18;
  static const double ecoMaxKmh = 60;
  static const double ecoThrottleMarginKmh = 2;
  static const double emptyFuelMv = 2800;
  static const double fuelPercentPerMeter = 0.0004;
  static const double fullFuelMv = 600;
  static const double kmhPerMetrePerSecond = 3.6;

  static const Duration autoStopAfter = Duration(seconds: 3);
  static const Duration blinkHalfPeriod = Duration(milliseconds: 330);

  final double lowFuelPercent;

  bool _autoStopArmed = false;
  bool _autoStopped = false;
  bool fiWarning = false;
  bool fuelSignalOk = true;
  bool highBeam = false;
  bool ignition = true;
  bool leftSwitch = false;
  bool rightSwitch = false;
  bool sideStand = false;
  bool speedSignalOk = true;
  bool stopStartSwitch = true;

  double batteryMv = 12600;
  double fuelPercent = 62;
  double odometerM = 18420000;
  double speedKmh = 0;
  double targetSpeedKmh = 0;
  double tripAM = 36400;
  double tripBM = 1200;

  Duration _blinkClock = Duration.zero;
  Duration _idleClock = Duration.zero;

  SimulatedBike({required this.lowFuelPercent});

  bool get eco => engineRunning && speedKmh > 0 && speedKmh <= ecoMaxKmh && targetSpeedKmh - speedKmh <= ecoThrottleMarginKmh;
  bool get engineRunning => ignition && !_autoStopped;
  bool get indicatorLampOn => (_blinkClock.inMilliseconds ~/ blinkHalfPeriod.inMilliseconds).isEven;

  StopStartMode get stopStart => !stopStartSwitch
      ? StopStartMode.off
      : _autoStopped
      ? StopStartMode.autoStopped
      : StopStartMode.enabled;

  void advance(Duration elapsed) {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _updateStopStart(elapsed);
    final target = engineRunning ? targetSpeedKmh : 0.0;
    speedKmh = speedKmh < target ? min(target, speedKmh + accelerationKmhPerSecond * seconds) : max(target, speedKmh - brakingKmhPerSecond * seconds);
    final meters = speedKmh / kmhPerMetrePerSecond * seconds;
    odometerM += meters;
    tripAM += meters;
    tripBM += meters;
    fuelPercent = max(0, fuelPercent - meters * fuelPercentPerMeter);
    _blinkClock = leftSwitch || rightSwitch ? _blinkClock + elapsed : Duration.zero;
  }

  void resetTrip(int tripId) {
    if (tripId == ResetTripMessage.tripA) tripAM = 0;
    if (tripId == ResetTripMessage.tripB) tripBM = 0;
  }

  TelemetryMessage toMessage() => TelemetryMessage(
    flags: TelemetryFlag.pack({
      if (ignition) TelemetryFlag.ignition,
      if (eco) TelemetryFlag.eco,
      if (stopStart != StopStartMode.off) TelemetryFlag.stopStartEnabled,
      if (stopStart == StopStartMode.autoStopped) TelemetryFlag.engineAutoStopped,
      if (leftSwitch && indicatorLampOn) TelemetryFlag.left,
      if (rightSwitch && indicatorLampOn) TelemetryFlag.right,
      if (highBeam) TelemetryFlag.highBeam,
      if (fiWarning) TelemetryFlag.fiWarning,
      if (sideStand) TelemetryFlag.sideStand,
      if (fuelPercent <= lowFuelPercent) TelemetryFlag.lowFuel,
      if (speedSignalOk) TelemetryFlag.speedSignalOk,
      if (fuelSignalOk) TelemetryFlag.fuelSignalOk,
    }),
    fuelPercentX10: (fuelPercent * 10).round().clamp(0, 1000),
    fuelRawMv: (emptyFuelMv + (fullFuelMv - emptyFuelMv) * fuelPercent / 100).round(),
    odometerM: odometerM.round(),
    speedKmhX10: (speedKmh * 10).round(),
    tripAM: tripAM.round(),
    tripBM: tripBM.round(),
  );

  void _updateStopStart(Duration elapsed) {
    if (!ignition) _autoStopArmed = false;
    if (speedKmh > autoStopArmKmh) _autoStopArmed = true;
    final idling = ignition && stopStartSwitch && targetSpeedKmh == 0 && speedKmh == 0;
    _idleClock = idling ? _idleClock + elapsed : Duration.zero;
    if (!idling) _autoStopped = false;
    if (!_autoStopArmed || _idleClock < autoStopAfter) return;
    _autoStopped = true;
    _autoStopArmed = false;
  }
}
