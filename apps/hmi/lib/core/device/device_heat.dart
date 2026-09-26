final class DeviceHeat {
  final double? batteryCelsius;

  final int thermalStatus;

  const DeviceHeat({this.batteryCelsius, required this.thermalStatus});

  factory DeviceHeat.fromMap(Map<Object?, Object?> map) => DeviceHeat(batteryCelsius: (map['batteryCelsius'] as num?)?.toDouble(), thermalStatus: map['thermalStatus'] as int? ?? 0);
}
