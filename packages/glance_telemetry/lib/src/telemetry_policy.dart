final class TelemetryPolicy {
  static const TelemetryPolicy standard = TelemetryPolicy();

  final double ridingLockAboveKmh;
  final double spikeKmhPer100Ms;

  final Duration fuelStaleAfter;
  final Duration linkStaleAfter;
  final Duration odometerStaleAfter;
  final Duration statusStaleAfter;
  final Duration tick;
  final Duration unlockAfter;

  const TelemetryPolicy({
    this.ridingLockAboveKmh = 5,
    this.spikeKmhPer100Ms = 40,
    this.fuelStaleAfter = const Duration(seconds: 3),
    this.linkStaleAfter = const Duration(milliseconds: 500),
    this.odometerStaleAfter = const Duration(seconds: 3),
    this.statusStaleAfter = const Duration(seconds: 3),
    this.tick = const Duration(milliseconds: 50),
    this.unlockAfter = const Duration(seconds: 3),
  });
}
