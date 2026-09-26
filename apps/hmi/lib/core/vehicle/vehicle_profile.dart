import 'package:yaml/yaml.dart';

final class VehicleProfile {
  static const String asset = 'assets/vehicles/ray_zr_125.yaml';

  final bool eco;
  final bool fiWarning;
  final bool highBeam;
  final bool leftIndicator;
  final bool rightIndicator;
  final bool sideStand;
  final bool stopStart;

  final double? maxDisplayKmh;

  final int? batteryLowMv;

  final String name;

  const VehicleProfile({
    required this.eco,
    required this.fiWarning,
    required this.highBeam,
    required this.leftIndicator,
    required this.rightIndicator,
    required this.sideStand,
    required this.stopStart,
    this.maxDisplayKmh,
    this.batteryLowMv,
    required this.name,
  });

  factory VehicleProfile.fromYaml(String source) {
    final root = loadYaml(source) as YamlMap;
    final signals = root['signals'] as YamlMap;
    return VehicleProfile(
      eco: signals['eco'] == true,
      fiWarning: signals['fi_warning'] == true,
      highBeam: signals['high_beam'] == true,
      leftIndicator: signals['left_indicator'] == true,
      rightIndicator: signals['right_indicator'] == true,
      sideStand: signals['side_stand'] == true,
      stopStart: signals['stop_start'] == true,
      maxDisplayKmh: ((root['speed'] as YamlMap)['max_display_kmh'] as num?)?.toDouble(),
      batteryLowMv: (root['electrical'] as YamlMap?)?['battery_low_mv'] as int?,
      name: root['name'] as String,
    );
  }
}
