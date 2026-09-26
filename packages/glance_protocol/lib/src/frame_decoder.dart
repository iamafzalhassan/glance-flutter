import 'dart:typed_data';

import 'crc16.dart';
import 'frame.dart';
import 'message_type.dart';
import 'protocol_message.dart';

enum FrameRejection { badCrc, badLength, unknownType, unsupportedVersion }

sealed class DecodeEvent {
  const DecodeEvent();
}

final class FrameDecoded extends DecodeEvent {
  final Frame frame;

  const FrameDecoded(this.frame);
}

final class FrameRejected extends DecodeEvent {
  final FrameRejection reason;

  const FrameRejected(this.reason);
}

final class FrameDecoder {
  final List<int> _buffer = [];

  List<DecodeEvent> add(List<int> chunk) {
    _buffer.addAll(chunk);
    final events = <DecodeEvent>[];
    for (var event = _next(); event != null; event = _next()) {
      events.add(event);
    }
    return events;
  }

  void reset() => _buffer.clear();

  DecodeEvent? _next() {
    _skipToSync();
    if (_buffer.length < Frame.headerLength) return null;
    final payloadLength = _buffer[10] | (_buffer[11] << 8);
    if (payloadLength > Frame.maxPayloadLength) {
      _buffer.removeAt(0);
      return const FrameRejected(FrameRejection.badLength);
    }
    final payloadEnd = Frame.headerLength + payloadLength;
    final frameEnd = payloadEnd + Frame.crcLength;
    if (_buffer.length < frameEnd) return null;
    final crc = _buffer[payloadEnd] | (_buffer[payloadEnd + 1] << 8);
    if (crc != Crc16.compute(_buffer, 2, payloadEnd)) {
      _buffer.removeAt(0);
      return const FrameRejected(FrameRejection.badCrc);
    }
    final bytes = Uint8List.fromList(_buffer.sublist(0, frameEnd));
    _buffer.removeRange(0, frameEnd);
    return _parse(bytes);
  }

  void _skipToSync() {
    var index = 0;
    while (index < _buffer.length - 1 && !(_buffer[index] == Frame.syncA && _buffer[index + 1] == Frame.syncB)) {
      index++;
    }
    if (index == _buffer.length - 1 && _buffer[index] != Frame.syncA) index++;
    _buffer.removeRange(0, index);
  }

  DecodeEvent _parse(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    if (data.getUint8(2) != Frame.protocolVersion) return const FrameRejected(FrameRejection.unsupportedVersion);
    final type = MessageType.fromCode(data.getUint8(3));
    if (type == null) return const FrameRejected(FrameRejection.unknownType);
    final payloadLength = data.getUint16(10, Endian.little);
    if (payloadLength != type.payloadLength) return const FrameRejected(FrameRejection.badLength);
    final message = ProtocolMessage.read(type, ByteData.sublistView(bytes, Frame.headerLength, Frame.headerLength + payloadLength));
    return FrameDecoded(Frame(message: message, sequence: data.getUint16(4, Endian.little), timestampMs: data.getUint32(6, Endian.little)));
  }
}
