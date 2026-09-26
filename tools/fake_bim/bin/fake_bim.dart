import 'dart:io';

import 'package:fake_bim/fake_bim_server.dart';
import 'package:glance_telemetry/glance_telemetry.dart';

const double _simulatedLowFuelPercent = 15;

Future<void> main(List<String> args) async {
  final port = int.tryParse(_option(args, '--port') ?? '') ?? FakeBimServer.defaultPort;
  final speedKmh = double.tryParse(_option(args, '--speed') ?? '') ?? 0;
  final simulator = SimulatorSource(bike: SimulatedBike(lowFuelPercent: _simulatedLowFuelPercent)..targetSpeedKmh = speedKmh);
  final address = args.contains('--lan') ? InternetAddress.anyIPv4 : InternetAddress.loopbackIPv4;
  final server = await FakeBimServer(simulator: simulator).serve(address: address, port: port);
  stdout.writeln('fake_bim streaming ${speedKmh.round()} km/h on ws://${server.address.host}:${server.port}');
}

String? _option(List<String> args, String name) {
  final index = args.indexOf(name);
  return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
}
