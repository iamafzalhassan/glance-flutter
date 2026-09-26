import 'dart:async';

import 'package:web/web.dart' as web;

Future<void>? _loading;

Future<void> loadGoogleMaps(String apiKey) => _loading ??= _inject(apiKey);

Future<void> _inject(String apiKey) {
  final completer = Completer<void>();
  final script = web.HTMLScriptElement()
    ..async = true
    ..src = 'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeQueryComponent(apiKey)}';
  script.onLoad.first.then((_) => completer.complete());
  script.onError.first.then((_) => completer.completeError(StateError('Google Maps JavaScript API failed to load')));
  web.document.head?.append(script);
  return completer.future;
}
