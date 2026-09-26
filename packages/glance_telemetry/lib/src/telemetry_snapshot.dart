import 'package:glance_protocol/glance_protocol.dart';

import 'link_stats.dart';
import 'reading.dart';

final class TelemetrySnapshot {
  static const TelemetrySnapshot initial = TelemetrySnapshot(
    linkUp: false,
    ridingLocked: false,
    stats: LinkStats.empty,
    fuelPercent: Reading.missing(),
    speedKmh: Reading.missing(),
    bikeMv: Reading.missing(),
    flags: Reading.missing(),
    fuelRawMv: Reading.missing(),
    odometerM: Reading.missing(),
    tripAM: Reading.missing(),
    tripBM: Reading.missing(),
  );

  final bool linkUp;
  final bool ridingLocked;

  final int? firmwareVersion;

  final LinkStats stats;

  final Reading<double> fuelPercent;
  final Reading<double> speedKmh;

  final Reading<int> bikeMv;
  final Reading<int> flags;
  final Reading<int> fuelRawMv;
  final Reading<int> odometerM;
  final Reading<int> tripAM;
  final Reading<int> tripBM;

  const TelemetrySnapshot({
    required this.linkUp,
    required this.ridingLocked,
    this.firmwareVersion,
    required this.stats,
    required this.fuelPercent,
    required this.speedKmh,
    required this.bikeMv,
    required this.flags,
    required this.fuelRawMv,
    required this.odometerM,
    required this.tripAM,
    required this.tripBM,
  });

  bool has(TelemetryFlag flag) => (flags.liveValue ?? 0) & flag.mask != 0;
}
