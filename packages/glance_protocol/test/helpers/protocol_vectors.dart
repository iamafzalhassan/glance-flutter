import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:glance_protocol/glance_protocol.dart';

Map<String, dynamic> readVectors() => jsonDecode(File('../../tools/protocol/vectors.json').readAsStringSync()) as Map<String, dynamic>;

Uint8List hexBytes(String hex) => Uint8List.fromList([for (var index = 0; index < hex.length; index += 2) int.parse(hex.substring(index, index + 2), radix: 16)]);

List<ProtocolVector> readFrameVectors() => [for (final json in readVectors()['frames'] as List) ProtocolVector.fromJson(json as Map<String, dynamic>)];

final class ProtocolVector {
  final String name;

  final Frame frame;

  final Uint8List bytes;

  const ProtocolVector({required this.name, required this.frame, required this.bytes});

  factory ProtocolVector.fromJson(Map<String, dynamic> json) => ProtocolVector(
    name: json['name'] as String,
    frame: Frame(message: _message(json['type'] as String, json['fields'] as Map<String, dynamic>), sequence: json['sequence'] as int, timestampMs: json['timestampMs'] as int),
    bytes: hexBytes(json['bytes'] as String),
  );

  static ProtocolMessage _message(String type, Map<String, dynamic> fields) => switch (type) {
    'telemetry' => TelemetryMessage(
      flags: fields['flags'] as int,
      fuelPercentX10: fields['fuelPercentX10'] as int,
      fuelRawMv: fields['fuelRawMv'] as int,
      odometerM: fields['odometerM'] as int,
      speedKmhX10: fields['speedKmhX10'] as int,
      tripAM: fields['tripAM'] as int,
      tripBM: fields['tripBM'] as int,
    ),
    'status' => StatusMessage(bikeMv: fields['bikeMv'] as int, firmwareVersion: fields['firmwareVersion'] as int, signalHealth: fields['signalHealth'] as int),
    'event' => EventMessage(eventCode: fields['eventCode'] as int, value: fields['value'] as int),
    'ack' => AckMessage(code: fields['code'] as int),
    'setOdometer' => SetOdometerMessage(odometerM: fields['odometerM'] as int),
    'resetTrip' => ResetTripMessage(tripId: fields['tripId'] as int),
    'setWheelCalibration' => SetWheelCalibrationMessage(factorX10000: fields['factorX10000'] as int),
    'saveFuelPoint' => SaveFuelPointMessage(percent: fields['percent'] as int),
    'requestRawSignals' => RequestRawSignalsMessage(enabled: fields['enabled'] as bool),
    'ping' => const PingMessage(),
    _ => throw ArgumentError.value(type, 'type'),
  };
}
