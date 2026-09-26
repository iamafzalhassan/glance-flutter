import 'package:flutter/services.dart';
import 'package:glance_maps/glance_maps.dart';

import 'device_control.dart';
import 'device_heat.dart';
import 'device_location.dart';

final class AndroidDeviceControl implements DeviceControl {
  static const EventChannel _heatChannel = EventChannel('glance/device/heat');
  static const EventChannel _locationChannel = EventChannel('glance/device/location');
  static const EventChannel _luxChannel = EventChannel('glance/device/lux');

  static const MethodChannel _channel = MethodChannel('glance/device');

  const AndroidDeviceControl();

  @override
  Stream<DeviceHeat> get heat => _heatChannel.receiveBroadcastStream().map((event) => DeviceHeat.fromMap(event as Map<Object?, Object?>));

  @override
  Stream<DeviceLocation> get location => _locationChannel.receiveBroadcastStream().map((event) => DeviceLocation.fromMap(event as Map<Object?, Object?>));

  @override
  Stream<double> get ambientLux => _luxChannel.receiveBroadcastStream().map((event) => (event as num).toDouble());

  @override
  Future<void> enterKiosk() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await _channel.invokeMethod<void>('enterKiosk');
  }

  @override
  Future<void> exitKiosk() async {
    await _channel.invokeMethod<void>('exitKiosk');
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const []);
  }

  @override
  Future<void> lockScreen() => _channel.invokeMethod<void>('lockScreen');

  @override
  Future<MapsCredentials?> mapsCredentials() async {
    final values = await _channel.invokeMapMethod<String, Object?>('mapsCredentials');
    final apiKey = values?['apiKey'] as String?;
    if (apiKey == null || apiKey.isEmpty) return null;
    return MapsCredentials(apiKey: apiKey, headers: {'X-Android-Cert': values?['certificate'] as String? ?? '', 'X-Android-Package': values?['package'] as String? ?? ''});
  }

  @override
  Future<void> setBrightness(double? level) => _channel.invokeMethod<void>('setBrightness', level);

  @override
  Future<void> setKeepScreenOn(bool keepOn) => _channel.invokeMethod<void>('setKeepScreenOn', keepOn);

  @override
  Future<void> setReducedFrameRate(bool reduced) => _channel.invokeMethod<void>('setReducedFrameRate', reduced);

  @override
  Future<void> wakeScreen() => _channel.invokeMethod<void>('wakeScreen');
}
