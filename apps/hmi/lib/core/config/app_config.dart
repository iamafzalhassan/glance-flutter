enum TelemetrySourceKind { studio, simulator, websocket }

final class AppConfig {
  static const String _mapsApiKey = String.fromEnvironment('MAPS_API_KEY');
  static const String _source = String.fromEnvironment('SOURCE', defaultValue: 'simulator');
  static const String version = '0.1.0';
  static const String _webSocketUrl = String.fromEnvironment('BIM_WS_URL', defaultValue: 'ws://localhost:8787');

  final String mapsApiKey;

  final TelemetrySourceKind source;

  final Uri webSocketUri;

  const AppConfig({required this.mapsApiKey, required this.source, required this.webSocketUri});

  factory AppConfig.fromEnvironment() => AppConfig(
    mapsApiKey: _mapsApiKey,
    source: TelemetrySourceKind.values.firstWhere((kind) => kind.name == _source, orElse: () => TelemetrySourceKind.simulator),
    webSocketUri: Uri.parse(_webSocketUrl),
  );

  bool get isStudio => source == TelemetrySourceKind.studio;
}
