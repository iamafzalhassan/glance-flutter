import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'telemetry_source.dart';

final class WebSocketSource implements TelemetrySource {
  static const Duration retryAfter = Duration(seconds: 1);

  final StreamController<List<int>> _bytes = StreamController.broadcast();

  final Uri _uri;

  bool _closed = false;

  StreamSubscription<Object?>? _subscription;

  Timer? _retry;

  WebSocketChannel? _channel;

  WebSocketSource(this._uri) {
    _connect();
  }

  void _connect() {
    final channel = WebSocketChannel.connect(_uri);
    channel.ready.ignore();
    _channel = channel;
    _subscription = channel.stream.listen(_receive, onDone: _reconnectLater, onError: (Object _) {});
  }

  void _receive(Object? message) {
    if (message is List<int>) _bytes.add(message);
  }

  void _reconnectLater() {
    if (!_closed) _retry = Timer(retryAfter, _connect);
  }

  @override
  Stream<List<int>> get bytes => _bytes.stream;

  @override
  Future<void> close() async {
    _closed = true;
    _retry?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _bytes.close();
  }

  @override
  Future<void> send(List<int> bytes) async => _channel?.sink.add(bytes);
}
