import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vehicle/battery_watch.dart';
import '../vehicle/fuel_range_learner.dart';
import '../vehicle/vehicle_profile.dart';
import 'settings_providers.dart';
import 'telemetry_providers.dart';

const int _metersPerKm = 1000;

final vehicleProfileProvider = FutureProvider<VehicleProfile>((ref) async => VehicleProfile.fromYaml(await rootBundle.loadString(VehicleProfile.asset)));

final batteryLowProvider = NotifierProvider<BatteryLowNotifier, bool>(BatteryLowNotifier.new);

final fuelRangeKmProvider = NotifierProvider<FuelRangeNotifier, int?>(FuelRangeNotifier.new);

final serviceRemainingKmProvider = Provider<int?>((ref) {
  final dueKm = ref.watch(settingsProvider.select((settings) => settings.serviceDueKm));
  final odometerKm = ref.watch(telemetryProvider.select((snapshot) => snapshot.odometerM.value == null ? null : snapshot.odometerM.value! ~/ _metersPerKm));
  return dueKm <= 0 || odometerKm == null ? null : dueKm - odometerKm;
});

class BatteryLowNotifier extends Notifier<bool> {
  static const Duration checkEvery = Duration(seconds: 1);

  final BatteryWatch _watch = BatteryWatch();

  final Stopwatch _clock = Stopwatch()..start();

  void _check() {
    final millivolts = ref.read(telemetryProvider).bikeMv.liveValue;
    final lowMv = ref.read(vehicleProfileProvider).value?.batteryLowMv;
    final low = millivolts != null && lowMv != null && _watch.update(lowMv: lowMv, millivolts: millivolts, now: _clock.elapsed);
    if (low != state) state = low;
  }

  @override
  bool build() {
    final timer = Timer.periodic(checkEvery, (_) => _check());
    ref.onDispose(timer.cancel);
    return false;
  }
}

class FuelRangeNotifier extends Notifier<int?> {
  final FuelRangeLearner _learner = FuelRangeLearner();

  void _update((double?, int?) reading) {
    final (fuelPercent, odometerM) = reading;
    if (fuelPercent == null || odometerM == null) {
      state = null;
      return;
    }
    final settings = ref.read(settingsProvider);
    final learned = _learner.learn(fuelPercent: fuelPercent, learned: settings.fuelPercentPerKm, odometerM: odometerM);
    if (learned != settings.fuelPercentPerKm) ref.read(settingsProvider.notifier).update(settings.copyWith(fuelPercentPerKm: learned));
    state = FuelRangeLearner.rangeKm(fuelPercent, learned);
  }

  @override
  int? build() {
    ref.listen(telemetryProvider.select((snapshot) => (snapshot.fuelPercent.liveValue, snapshot.odometerM.liveValue)), (_, reading) => _update(reading));
    return null;
  }
}
