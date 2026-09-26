import 'package:flutter/widgets.dart';

final class MapPalette {
  static const MapPalette day = MapPalette(base: Color(0xFFE9EEF3), road: Color(0xFFFFFFFF));
  static const MapPalette night = MapPalette(base: Color(0xFF0E1726), road: Color(0xFF2A3547));

  final Color base;
  final Color road;

  const MapPalette({required this.base, required this.road});
}
