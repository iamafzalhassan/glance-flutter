import 'package:flutter/material.dart';

class NightRoadColors extends ThemeExtension<NightRoadColors> {
  static const NightRoadColors day = NightRoadColors(
    accentNav: Color(0xFF0062CC),
    bgBase: Color(0xFFF7F7F7),
    bgOverlay: Color(0xFFD7D7D7),
    bgPanel: Color(0xFFFFFFFF),
    bgRaised: Color(0xFFE8E8E8),
    lineSubtle: Color(0xFFD7D7D7),
    stateDanger: Color(0xFFD70015),
    stateEco: Color(0xFF1E9E43),
    stateHighBeam: Color(0xFF1F5FE0),
    stateIndicator: Color(0xFF1E9E43),
    stateWarn: Color(0xFFC77C00),
    textMuted: Color(0xFF7B7B7B),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF31373E),
  );
  static const NightRoadColors night = NightRoadColors(
    accentNav: Color(0xFF007AFF),
    bgBase: Color(0xFF000000),
    bgOverlay: Color(0xFF25292E),
    bgPanel: Color(0xFF121212),
    bgRaised: Color(0xFF191919),
    lineSubtle: Color(0xFF31373E),
    stateDanger: Color(0xFFFF453A),
    stateEco: Color(0xFF30D158),
    stateHighBeam: Color(0xFF3D7BFF),
    stateIndicator: Color(0xFF30D158),
    stateWarn: Color(0xFFFFB020),
    textMuted: Color(0xFF9A9C9D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFE8E8E8),
  );

  final Color accentNav;
  final Color bgBase;
  final Color bgOverlay;
  final Color bgPanel;
  final Color bgRaised;
  final Color lineSubtle;
  final Color stateDanger;
  final Color stateEco;
  final Color stateHighBeam;
  final Color stateIndicator;
  final Color stateWarn;
  final Color textMuted;
  final Color textPrimary;
  final Color textSecondary;

  const NightRoadColors({
    required this.accentNav,
    required this.bgBase,
    required this.bgOverlay,
    required this.bgPanel,
    required this.bgRaised,
    required this.lineSubtle,
    required this.stateDanger,
    required this.stateEco,
    required this.stateHighBeam,
    required this.stateIndicator,
    required this.stateWarn,
    required this.textMuted,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  NightRoadColors copyWith({
    Color? accentNav,
    Color? bgBase,
    Color? bgOverlay,
    Color? bgPanel,
    Color? bgRaised,
    Color? lineSubtle,
    Color? stateDanger,
    Color? stateEco,
    Color? stateHighBeam,
    Color? stateIndicator,
    Color? stateWarn,
    Color? textMuted,
    Color? textPrimary,
    Color? textSecondary,
  }) => NightRoadColors(
    accentNav: accentNav ?? this.accentNav,
    bgBase: bgBase ?? this.bgBase,
    bgOverlay: bgOverlay ?? this.bgOverlay,
    bgPanel: bgPanel ?? this.bgPanel,
    bgRaised: bgRaised ?? this.bgRaised,
    lineSubtle: lineSubtle ?? this.lineSubtle,
    stateDanger: stateDanger ?? this.stateDanger,
    stateEco: stateEco ?? this.stateEco,
    stateHighBeam: stateHighBeam ?? this.stateHighBeam,
    stateIndicator: stateIndicator ?? this.stateIndicator,
    stateWarn: stateWarn ?? this.stateWarn,
    textMuted: textMuted ?? this.textMuted,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
  );

  @override
  NightRoadColors lerp(NightRoadColors? other, double t) {
    if (other == null) return this;
    return NightRoadColors(
      accentNav: Color.lerp(accentNav, other.accentNav, t)!,
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      bgPanel: Color.lerp(bgPanel, other.bgPanel, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      lineSubtle: Color.lerp(lineSubtle, other.lineSubtle, t)!,
      stateDanger: Color.lerp(stateDanger, other.stateDanger, t)!,
      stateEco: Color.lerp(stateEco, other.stateEco, t)!,
      stateHighBeam: Color.lerp(stateHighBeam, other.stateHighBeam, t)!,
      stateIndicator: Color.lerp(stateIndicator, other.stateIndicator, t)!,
      stateWarn: Color.lerp(stateWarn, other.stateWarn, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
