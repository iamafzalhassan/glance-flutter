import 'dart:io';

import 'package:glance_telemetry/glance_telemetry.dart';

final class FakeBimServer {
  static const int defaultPort = 8787;

  final SimulatorSource simulator;

  FakeBimServer({required this.simulator});

  Future<HttpServer> serve({required int port, required InternetAddress address}) async {
    final server = await HttpServer.bind(address, port);
    server.transform(WebSocketTransformer()).listen(_attach);
    return server;
  }

  void _attach(WebSocket socket) {
    final subscription = simulator.bytes.listen(socket.add);
    socket.listen((message) {
      if (message is List<int>) simulator.send(message);
    }, onDone: subscription.cancel);
  }
}
