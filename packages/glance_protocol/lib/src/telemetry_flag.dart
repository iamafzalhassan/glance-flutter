enum TelemetryFlag {
  ignition(0),
  eco(1),
  stopStartEnabled(2),
  engineAutoStopped(3),
  left(4),
  right(5),
  highBeam(6),
  fiWarning(7),
  sideStand(8),
  lowFuel(9),
  speedSignalOk(10),
  fuelSignalOk(11);

  final int bit;

  const TelemetryFlag(this.bit);

  int get mask => 1 << bit;

  static int pack(Set<TelemetryFlag> flags) => flags.fold(0, (packed, flag) => packed | flag.mask);
}
