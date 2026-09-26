import 'dart:typed_data';

import 'message_type.dart';
import 'telemetry_flag.dart';

sealed class ProtocolMessage {
  const ProtocolMessage();

  MessageType get type;

  void write(ByteData payload);

  static ProtocolMessage read(MessageType type, ByteData payload) => switch (type) {
    MessageType.telemetry => TelemetryMessage.read(payload),
    MessageType.status => StatusMessage.read(payload),
    MessageType.event => EventMessage.read(payload),
    MessageType.ack => AckMessage.read(payload),
    MessageType.setOdometer => SetOdometerMessage.read(payload),
    MessageType.resetTrip => ResetTripMessage.read(payload),
    MessageType.setWheelCalibration => SetWheelCalibrationMessage.read(payload),
    MessageType.saveFuelPoint => SaveFuelPointMessage.read(payload),
    MessageType.requestRawSignals => RequestRawSignalsMessage.read(payload),
    MessageType.ping => const PingMessage(),
  };
}

final class TelemetryMessage extends ProtocolMessage {
  final int flags;
  final int fuelPercentX10;
  final int fuelRawMv;
  final int odometerM;
  final int speedKmhX10;
  final int tripAM;
  final int tripBM;

  const TelemetryMessage({required this.flags, required this.fuelPercentX10, required this.fuelRawMv, required this.odometerM, required this.speedKmhX10, required this.tripAM, required this.tripBM});

  factory TelemetryMessage.read(ByteData payload) => TelemetryMessage(
    flags: payload.getUint16(18, Endian.little),
    fuelPercentX10: payload.getUint16(14, Endian.little),
    fuelRawMv: payload.getUint16(16, Endian.little),
    odometerM: payload.getUint32(2, Endian.little),
    speedKmhX10: payload.getUint16(0, Endian.little),
    tripAM: payload.getUint32(6, Endian.little),
    tripBM: payload.getUint32(10, Endian.little),
  );

  bool has(TelemetryFlag flag) => flags & flag.mask != 0;

  @override
  MessageType get type => MessageType.telemetry;

  @override
  void write(ByteData payload) {
    payload.setUint16(0, speedKmhX10, Endian.little);
    payload.setUint32(2, odometerM, Endian.little);
    payload.setUint32(6, tripAM, Endian.little);
    payload.setUint32(10, tripBM, Endian.little);
    payload.setUint16(14, fuelPercentX10, Endian.little);
    payload.setUint16(16, fuelRawMv, Endian.little);
    payload.setUint16(18, flags, Endian.little);
  }

  @override
  bool operator ==(Object other) =>
      other is TelemetryMessage &&
      other.flags == flags &&
      other.fuelPercentX10 == fuelPercentX10 &&
      other.fuelRawMv == fuelRawMv &&
      other.odometerM == odometerM &&
      other.speedKmhX10 == speedKmhX10 &&
      other.tripAM == tripAM &&
      other.tripBM == tripBM;

  @override
  int get hashCode => Object.hash(flags, fuelPercentX10, fuelRawMv, odometerM, speedKmhX10, tripAM, tripBM);
}

final class StatusMessage extends ProtocolMessage {
  final int bikeMv;
  final int firmwareVersion;
  final int signalHealth;

  const StatusMessage({required this.bikeMv, required this.firmwareVersion, required this.signalHealth});

  factory StatusMessage.read(ByteData payload) => StatusMessage(bikeMv: payload.getUint16(0, Endian.little), firmwareVersion: payload.getUint32(2, Endian.little), signalHealth: payload.getUint8(6));

  @override
  MessageType get type => MessageType.status;

  @override
  void write(ByteData payload) {
    payload.setUint16(0, bikeMv, Endian.little);
    payload.setUint32(2, firmwareVersion, Endian.little);
    payload.setUint8(6, signalHealth);
  }

  @override
  bool operator ==(Object other) => other is StatusMessage && other.bikeMv == bikeMv && other.firmwareVersion == firmwareVersion && other.signalHealth == signalHealth;

  @override
  int get hashCode => Object.hash(bikeMv, firmwareVersion, signalHealth);
}

final class EventMessage extends ProtocolMessage {
  final int eventCode;
  final int value;

  const EventMessage({required this.eventCode, required this.value});

  factory EventMessage.read(ByteData payload) => EventMessage(eventCode: payload.getUint8(0), value: payload.getUint16(1, Endian.little));

  @override
  MessageType get type => MessageType.event;

  @override
  void write(ByteData payload) {
    payload.setUint8(0, eventCode);
    payload.setUint16(1, value, Endian.little);
  }

  @override
  bool operator ==(Object other) => other is EventMessage && other.eventCode == eventCode && other.value == value;

  @override
  int get hashCode => Object.hash(eventCode, value);
}

final class AckMessage extends ProtocolMessage {
  final int code;

  const AckMessage({required this.code});

  factory AckMessage.read(ByteData payload) => AckMessage(code: payload.getUint8(0));

  @override
  MessageType get type => MessageType.ack;

  @override
  void write(ByteData payload) => payload.setUint8(0, code);

  @override
  bool operator ==(Object other) => other is AckMessage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

final class SetOdometerMessage extends ProtocolMessage {
  final int odometerM;

  const SetOdometerMessage({required this.odometerM});

  factory SetOdometerMessage.read(ByteData payload) => SetOdometerMessage(odometerM: payload.getUint32(0, Endian.little));

  @override
  MessageType get type => MessageType.setOdometer;

  @override
  void write(ByteData payload) => payload.setUint32(0, odometerM, Endian.little);

  @override
  bool operator ==(Object other) => other is SetOdometerMessage && other.odometerM == odometerM;

  @override
  int get hashCode => odometerM.hashCode;
}

final class ResetTripMessage extends ProtocolMessage {
  static const int tripA = 0;
  static const int tripB = 1;

  final int tripId;

  const ResetTripMessage({required this.tripId});

  factory ResetTripMessage.read(ByteData payload) => ResetTripMessage(tripId: payload.getUint8(0));

  @override
  MessageType get type => MessageType.resetTrip;

  @override
  void write(ByteData payload) => payload.setUint8(0, tripId);

  @override
  bool operator ==(Object other) => other is ResetTripMessage && other.tripId == tripId;

  @override
  int get hashCode => tripId.hashCode;
}

final class SetWheelCalibrationMessage extends ProtocolMessage {
  final int factorX10000;

  const SetWheelCalibrationMessage({required this.factorX10000});

  factory SetWheelCalibrationMessage.read(ByteData payload) => SetWheelCalibrationMessage(factorX10000: payload.getUint32(0, Endian.little));

  @override
  MessageType get type => MessageType.setWheelCalibration;

  @override
  void write(ByteData payload) => payload.setUint32(0, factorX10000, Endian.little);

  @override
  bool operator ==(Object other) => other is SetWheelCalibrationMessage && other.factorX10000 == factorX10000;

  @override
  int get hashCode => factorX10000.hashCode;
}

final class SaveFuelPointMessage extends ProtocolMessage {
  final int percent;

  const SaveFuelPointMessage({required this.percent});

  factory SaveFuelPointMessage.read(ByteData payload) => SaveFuelPointMessage(percent: payload.getUint8(0));

  @override
  MessageType get type => MessageType.saveFuelPoint;

  @override
  void write(ByteData payload) => payload.setUint8(0, percent);

  @override
  bool operator ==(Object other) => other is SaveFuelPointMessage && other.percent == percent;

  @override
  int get hashCode => percent.hashCode;
}

final class RequestRawSignalsMessage extends ProtocolMessage {
  final bool enabled;

  const RequestRawSignalsMessage({required this.enabled});

  factory RequestRawSignalsMessage.read(ByteData payload) => RequestRawSignalsMessage(enabled: payload.getUint8(0) != 0);

  @override
  MessageType get type => MessageType.requestRawSignals;

  @override
  void write(ByteData payload) => payload.setUint8(0, enabled ? 1 : 0);

  @override
  bool operator ==(Object other) => other is RequestRawSignalsMessage && other.enabled == enabled;

  @override
  int get hashCode => enabled.hashCode;
}

final class PingMessage extends ProtocolMessage {
  const PingMessage();

  @override
  MessageType get type => MessageType.ping;

  @override
  void write(ByteData payload) {}

  @override
  bool operator ==(Object other) => other is PingMessage;

  @override
  int get hashCode => type.hashCode;
}
