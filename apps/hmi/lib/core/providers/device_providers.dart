import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';

import '../device/android_device_control.dart';
import '../device/brightness_policy.dart';
import '../device/device_control.dart';
import '../device/device_heat.dart';
import '../device/heat_policy.dart';
import '../device/no_device_control.dart';
import 'settings_providers.dart';
import 'telemetry_providers.dart';

enum DevicePower { awake, summary, parked, asleep }

final deviceControlProvider = Provider<DeviceControl>((ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? const AndroidDeviceControl() : const NoDeviceControl());

final ambientLuxProvider = StreamProvider<double>((ref) => ref.watch(deviceControlProvider).ambientLux);

final deviceHeatProvider = StreamProvider<DeviceHeat>((ref) => ref.watch(deviceControlProvider).heat);

final overheatedProvider = NotifierProvider<OverheatedNotifier, bool>(OverheatedNotifier.new);

final ignitionProvider = Provider<bool?>((ref) => ref.watch(telemetryProvider.select((snapshot) => snapshot.linkUp ? snapshot.has(TelemetryFlag.ignition) : null)));

final devicePowerProvider = NotifierProvider<DevicePowerNotifier, DevicePower>(DevicePowerNotifier.new);

class OverheatedNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(deviceHeatProvider, (_, next) {
      final heat = next.value;
      if (heat != null) state = HeatPolicy.standard.isHot(heat, wasHot: state);
    });
    return false;
  }
}

class DevicePowerNotifier extends Notifier<DevicePower> {
  static const Duration sleepAfter = Duration(minutes: 2);
  static const Duration summaryFor = Duration(seconds: 10);

  Timer? _stageTimer;

  void _onIgnition(bool? ignition) {
    if (ignition == null) return;
    final control = ref.read(deviceControlProvider);
    _stageTimer?.cancel();
    if (ignition) {
      state = DevicePower.awake;
      unawaited(control.setKeepScreenOn(true));
      unawaited(control.wakeScreen());
    } else {
      state = DevicePower.summary;
      _stageTimer = Timer(summaryFor, _park);
    }
    _applyDisplay();
  }

  void _park() {
    state = DevicePower.parked;
    _stageTimer = Timer(sleepAfter, _sleep);
    _applyDisplay();
  }

  void _sleep() {
    final control = ref.read(deviceControlProvider);
    state = DevicePower.asleep;
    unawaited(control.setKeepScreenOn(false));
    unawaited(control.lockScreen());
  }

  void _applyDisplay() {
    final control = ref.read(deviceControlProvider);
    final hot = ref.read(overheatedProvider);
    final lux = ref.read(ambientLuxProvider).value;
    final policy = BrightnessPolicy(ridingFloor: ref.read(settingsProvider).brightnessFloor);
    if (state == DevicePower.parked || state == DevicePower.asleep) {
      unawaited(control.setBrightness(policy.parkedLevel));
      return;
    }
    unawaited(control.setBrightness(lux == null ? (hot ? policy.heatCap : null) : policy.ridingLevel(hot: hot, lux: lux)));
  }

  @override
  DevicePower build() {
    final control = ref.watch(deviceControlProvider);
    ref.listen(ignitionProvider, (_, ignition) => _onIgnition(ignition));
    ref.listen(ambientLuxProvider, (_, _) => _applyDisplay());
    ref.listen(settingsProvider.select((settings) => settings.brightnessFloor), (_, _) => _applyDisplay());
    ref.listen(overheatedProvider, (_, hot) {
      unawaited(control.setReducedFrameRate(hot));
      _applyDisplay();
    });
    ref.onDispose(() => _stageTimer?.cancel());
    scheduleMicrotask(() async {
      await control.enterKiosk();
      await control.setKeepScreenOn(true);
      _applyDisplay();
    });
    return DevicePower.awake;
  }
}
