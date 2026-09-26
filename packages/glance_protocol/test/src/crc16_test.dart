import 'package:glance_protocol/glance_protocol.dart';
import 'package:test/test.dart';

import '../helpers/protocol_vectors.dart';

void main() {
  test('matches the CRC-16/CCITT-FALSE check value from the shared vectors', () {
    final crc = readVectors()['crc'] as Map<String, dynamic>;
    expect(Crc16.compute(hexBytes(crc['check'] as String)), crc['value']);
  });

  test('covers only the requested range', () {
    final bytes = [0xFF, ...'123456789'.codeUnits, 0xFF];
    expect(Crc16.compute(bytes, 1, 10), 0x29B1);
  });

  test('is the initial value for an empty range', () => expect(Crc16.compute(const []), Crc16.initial));
}
