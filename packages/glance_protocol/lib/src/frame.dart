import 'dart:typed_data';

import 'crc16.dart';
import 'protocol_message.dart';

final class Frame {
  static const int crcLength = 2;
  static const int headerLength = 12;
  static const int maxPayloadLength = 64;
  static const int protocolVersion = 1;
  static const int syncA = 0xAA;
  static const int syncB = 0x55;

  final int sequence;
  final int timestampMs;

  final ProtocolMessage message;

  const Frame({required this.sequence, required this.timestampMs, required this.message});

  Uint8List encode() {
    final payloadLength = message.type.payloadLength;
    final payloadEnd = headerLength + payloadLength;
    final bytes = Uint8List(payloadEnd + crcLength);
    final data = ByteData.sublistView(bytes);
    data.setUint8(0, syncA);
    data.setUint8(1, syncB);
    data.setUint8(2, protocolVersion);
    data.setUint8(3, message.type.code);
    data.setUint16(4, sequence & 0xFFFF, Endian.little);
    data.setUint32(6, timestampMs & 0xFFFFFFFF, Endian.little);
    data.setUint16(10, payloadLength, Endian.little);
    message.write(ByteData.sublistView(bytes, headerLength, payloadEnd));
    data.setUint16(payloadEnd, Crc16.compute(bytes, 2, payloadEnd), Endian.little);
    return bytes;
  }

  @override
  bool operator ==(Object other) => other is Frame && other.sequence == sequence && other.timestampMs == timestampMs && other.message == message;

  @override
  int get hashCode => Object.hash(sequence, timestampMs, message);
}
