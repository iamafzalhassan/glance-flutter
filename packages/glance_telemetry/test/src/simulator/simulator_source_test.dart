import 'dart:math';

import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:test/test.dart';

void main() {
  test('unplugging leaves half a frame on the wire and then goes quiet', () async {
    final simulator = SimulatorSource(bike: SimulatedBike(lowFuelPercent: 15), random: Random(1));
    final chunks = <List<int>>[];
    final subscription = simulator.bytes.listen(chunks.add);
    simulator.unplug(const Duration(seconds: 3));
    simulator.tick(const Duration(milliseconds: 50));
    await Future<void>.delayed(Duration.zero);
    expect(chunks, hasLength(1));
    expect(FrameDecoder().add(chunks.single), isEmpty);
    await subscription.cancel();
    await simulator.close();
  });

  test('a normal tick sends one valid telemetry frame', () async {
    final simulator = SimulatorSource(bike: SimulatedBike(lowFuelPercent: 15), random: Random(1));
    final chunks = <List<int>>[];
    final subscription = simulator.bytes.listen(chunks.add);
    simulator.tick(const Duration(milliseconds: 50));
    await Future<void>.delayed(Duration.zero);
    final events = FrameDecoder().add([for (final chunk in chunks) ...chunk]);
    expect(events.whereType<FrameDecoded>().map((event) => event.frame.message), contains(isA<TelemetryMessage>()));
    await subscription.cancel();
    await simulator.close();
  });
}
