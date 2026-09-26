import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/device_providers.dart';
import '../../core/providers/telemetry_providers.dart';

final rideSummaryProvider = NotifierProvider<RideSummaryNotifier, RideSummary?>(RideSummaryNotifier.new);

final class RideSummary {
  final double averageKmh;
  final double maxKmh;

  final int distanceM;

  final Duration duration;

  const RideSummary({required this.averageKmh, required this.maxKmh, required this.distanceM, required this.duration});
}

class RideSummaryNotifier extends Notifier<RideSummary?> {
  double _maxKmh = 0;

  int? _startOdometerM;

  DateTime? _startedAt;

  void _onIgnition(bool? ignition) {
    if (ignition == true) _start();
    if (ignition == false) _finish();
  }

  void _start() {
    _startOdometerM = ref.read(telemetryProvider).odometerM.value;
    _startedAt = DateTime.now();
    _maxKmh = 0;
  }

  void _finish() {
    final startOdometerM = _startOdometerM;
    final startedAt = _startedAt;
    final odometerM = ref.read(telemetryProvider).odometerM.value;
    if (startOdometerM == null || startedAt == null || odometerM == null) return;
    final distanceM = odometerM - startOdometerM;
    final duration = DateTime.now().difference(startedAt);
    final hours = duration.inMilliseconds / Duration.millisecondsPerHour;
    state = RideSummary(averageKmh: hours > 0 ? distanceM / 1000 / hours : 0, distanceM: distanceM, duration: duration, maxKmh: _maxKmh);
    _startOdometerM = null;
    _startedAt = null;
  }

  void _onSpeed(double? speedKmh) {
    if (speedKmh != null && speedKmh > _maxKmh) _maxKmh = speedKmh;
  }

  @override
  RideSummary? build() {
    ref.listen(ignitionProvider, (_, ignition) => _onIgnition(ignition));
    ref.listen(telemetryProvider.select((snapshot) => snapshot.speedKmh.liveValue), (_, speed) => _onSpeed(speed));
    return null;
  }
}
