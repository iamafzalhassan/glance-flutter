import 'package:glance_maps/glance_maps.dart';

import 'device_control.dart';
import 'device_heat.dart';
import 'device_location.dart';

final class NoDeviceControl implements DeviceControl {
  const NoDeviceControl();

  @override
  Stream<DeviceHeat> get heat => const Stream.empty();

  @override
  Stream<DeviceLocation> get location => const Stream.empty();

  @override
  Stream<double> get ambientLux => const Stream.empty();

  @override
  Future<void> enterKiosk() async {}

  @override
  Future<void> exitKiosk() async {}

  @override
  Future<void> lockScreen() async {}

  @override
  Future<MapsCredentials?> mapsCredentials() async => null;

  @override
  Future<void> setBrightness(double? level) async {}

  @override
  Future<void> setKeepScreenOn(bool keepOn) async {}

  @override
  Future<void> setReducedFrameRate(bool reduced) async {}

  @override
  Future<void> wakeScreen() async {}
}
