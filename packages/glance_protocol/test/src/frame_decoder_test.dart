import 'package:glance_protocol/glance_protocol.dart';
import 'package:test/test.dart';

import '../helpers/protocol_vectors.dart';

void main() {
  final vectors = readFrameVectors();
  final telemetry = vectors.firstWhere((vector) => vector.name == 'telemetryCruise');

  for (final vector in vectors) {
    test('decodes ${vector.name}', () {
      final events = FrameDecoder().add(vector.bytes);
      expect(events, hasLength(1));
      expect((events.single as FrameDecoded).frame, vector.frame);
    });
  }

  test('decodes every vector from one concatenated stream', () {
    final events = FrameDecoder().add([for (final vector in vectors) ...vector.bytes]);
    expect([for (final event in events) (event as FrameDecoded).frame], [for (final vector in vectors) vector.frame]);
  });

  test('reassembles a frame delivered one byte at a time', () {
    final decoder = FrameDecoder();
    final events = [
      for (final byte in telemetry.bytes) ...decoder.add([byte]),
    ];
    expect(events, hasLength(1));
    expect((events.single as FrameDecoded).frame, telemetry.frame);
  });

  test('skips garbage before a frame, including a lone sync byte', () {
    final events = FrameDecoder().add([0x00, 0x13, Frame.syncA, 0x42, Frame.syncA, ...telemetry.bytes]);
    expect(events, hasLength(1));
    expect(events.single, isA<FrameDecoded>());
  });

  test('rejects a corrupted CRC and recovers on the next frame', () {
    final corrupted = [...telemetry.bytes];
    corrupted[14] ^= 0xFF;
    final events = FrameDecoder().add([...corrupted, ...telemetry.bytes]);
    expect(events.first, isA<FrameRejected>().having((event) => event.reason, 'reason', FrameRejection.badCrc));
    expect(events.last, isA<FrameDecoded>());
  });

  test('rejects an unsupported protocol version', () {
    final bytes = Frame(message: const PingMessage(), sequence: 1, timestampMs: 1).encode();
    bytes[2] = 2;
    final crc = Crc16.compute(bytes, 2, Frame.headerLength);
    bytes[Frame.headerLength] = crc & 0xFF;
    bytes[Frame.headerLength + 1] = crc >> 8;
    expect(FrameDecoder().add(bytes).single, isA<FrameRejected>().having((event) => event.reason, 'reason', FrameRejection.unsupportedVersion));
  });

  test('rejects an unknown message type', () {
    final bytes = Frame(message: const PingMessage(), sequence: 1, timestampMs: 1).encode();
    bytes[3] = 0x66;
    final crc = Crc16.compute(bytes, 2, Frame.headerLength);
    bytes[Frame.headerLength] = crc & 0xFF;
    bytes[Frame.headerLength + 1] = crc >> 8;
    expect(FrameDecoder().add(bytes).single, isA<FrameRejected>().having((event) => event.reason, 'reason', FrameRejection.unknownType));
  });

  test('rejects an impossible payload length without waiting for more bytes', () {
    final events = FrameDecoder().add([Frame.syncA, Frame.syncB, 1, 1, 0, 0, 0, 0, 0, 0, 0xFF, 0xFF]);
    expect(events.single, isA<FrameRejected>().having((event) => event.reason, 'reason', FrameRejection.badLength));
  });

  test('waits for the rest of a partial frame', () => expect(FrameDecoder().add(telemetry.bytes.sublist(0, 20)), isEmpty));
}
