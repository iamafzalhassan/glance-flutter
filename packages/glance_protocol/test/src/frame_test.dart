import 'package:glance_protocol/glance_protocol.dart';
import 'package:test/test.dart';

import '../helpers/protocol_vectors.dart';

void main() {
  for (final vector in readFrameVectors()) {
    test('encodes ${vector.name} byte for byte', () => expect(vector.frame.encode(), vector.bytes));
  }

  test('wraps sequence and timestamp into their field widths', () {
    final bytes = const Frame(message: PingMessage(), sequence: 0x10001, timestampMs: 0x100000002).encode();
    expect([bytes[4], bytes[5]], [0x01, 0x00]);
    expect([bytes[6], bytes[7], bytes[8], bytes[9]], [0x02, 0x00, 0x00, 0x00]);
  });
}
