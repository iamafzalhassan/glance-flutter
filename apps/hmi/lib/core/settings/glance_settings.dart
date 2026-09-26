enum ThemePreference { auto, night, day }

final class GlanceSettings {
  static const GlanceSettings defaults = GlanceSettings(reduceMotion: false, brightnessFloor: 0.35, fuelPercentPerKm: 0, serviceDueKm: 0, speedAlertKmh: 0, theme: ThemePreference.auto);

  final bool reduceMotion;

  final double brightnessFloor;
  final double fuelPercentPerKm;

  final int serviceDueKm;
  final int speedAlertKmh;

  final ThemePreference theme;

  const GlanceSettings({required this.reduceMotion, required this.brightnessFloor, required this.fuelPercentPerKm, required this.serviceDueKm, required this.speedAlertKmh, required this.theme});

  factory GlanceSettings.fromJson(Map<String, dynamic> json) => GlanceSettings(
    reduceMotion: json['reduceMotion'] as bool? ?? defaults.reduceMotion,
    brightnessFloor: (json['brightnessFloor'] as num?)?.toDouble() ?? defaults.brightnessFloor,
    fuelPercentPerKm: (json['fuelPercentPerKm'] as num?)?.toDouble() ?? defaults.fuelPercentPerKm,
    serviceDueKm: json['serviceDueKm'] as int? ?? defaults.serviceDueKm,
    speedAlertKmh: json['speedAlertKmh'] as int? ?? defaults.speedAlertKmh,
    theme: ThemePreference.values.firstWhere((theme) => theme.name == json['theme'], orElse: () => defaults.theme),
  );

  GlanceSettings copyWith({bool? reduceMotion, double? brightnessFloor, double? fuelPercentPerKm, int? serviceDueKm, int? speedAlertKmh, ThemePreference? theme}) => GlanceSettings(
    reduceMotion: reduceMotion ?? this.reduceMotion,
    brightnessFloor: brightnessFloor ?? this.brightnessFloor,
    fuelPercentPerKm: fuelPercentPerKm ?? this.fuelPercentPerKm,
    serviceDueKm: serviceDueKm ?? this.serviceDueKm,
    speedAlertKmh: speedAlertKmh ?? this.speedAlertKmh,
    theme: theme ?? this.theme,
  );

  Map<String, dynamic> toJson() => {'reduceMotion': reduceMotion, 'brightnessFloor': brightnessFloor, 'fuelPercentPerKm': fuelPercentPerKm, 'serviceDueKm': serviceDueKm, 'speedAlertKmh': speedAlertKmh, 'theme': theme.name};

  @override
  bool operator ==(Object other) =>
      other is GlanceSettings &&
      other.reduceMotion == reduceMotion &&
      other.brightnessFloor == brightnessFloor &&
      other.fuelPercentPerKm == fuelPercentPerKm &&
      other.serviceDueKm == serviceDueKm &&
      other.speedAlertKmh == speedAlertKmh &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(reduceMotion, brightnessFloor, fuelPercentPerKm, serviceDueKm, speedAlertKmh, theme);
}
