import 'package:glance_maps/glance_maps.dart';

import 'device_heat.dart';
import 'device_location.dart';

abstract interface class DeviceControl {
  Stream<DeviceHeat> get heat;

  Stream<DeviceLocation> get location;

  Stream<double> get ambientLux;

  Future<void> enterKiosk();

  Future<void> exitKiosk();

  Future<void> lockScreen();

  Future<MapsCredentials?> mapsCredentials();

  Future<void> setBrightness(double? level);

  Future<void> setKeepScreenOn(bool keepOn);

  Future<void> setReducedFrameRate(bool reduced);

  Future<void> wakeScreen();
}
