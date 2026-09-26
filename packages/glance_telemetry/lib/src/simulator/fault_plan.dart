final class FaultPlan {
  bool dropout = false;
  bool fuelSlosh = false;

  double crcErrorRate = 0;
  double spikeRate = 0;

  Duration delay = Duration.zero;
  Duration jitter = Duration.zero;
}
