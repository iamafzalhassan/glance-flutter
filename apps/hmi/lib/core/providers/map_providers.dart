import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_maps/glance_maps.dart';

import '../device/device_location.dart';
import 'device_providers.dart';
import 'telemetry_providers.dart';

const GeoPoint defaultMapCentre = GeoPoint(6.9271, 79.8612);

final useGoogleMapsProvider = Provider<bool>((ref) => ref.watch(appConfigProvider).mapsApiKey.isNotEmpty && (kIsWeb || defaultTargetPlatform == TargetPlatform.android));

final riderLocationProvider = StreamProvider<DeviceLocation>((ref) => ref.watch(deviceControlProvider).location);

final mapsClientProvider = FutureProvider<GoogleMapsClient?>((ref) async {
  final config = ref.watch(appConfigProvider);
  if (config.mapsApiKey.isEmpty) return null;
  final credentials = kIsWeb ? MapsCredentials(apiKey: config.mapsApiKey) : await ref.watch(deviceControlProvider).mapsCredentials();
  if (credentials == null) return null;
  final client = GoogleMapsClient(credentials);
  ref.onDispose(client.close);
  return client;
});
