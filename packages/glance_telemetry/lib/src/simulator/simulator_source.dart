import 'dart:async';
import 'dart:math';

import 'package:glance_protocol/glance_protocol.dart';

import '../telemetry_source.dart';
import 'fault_plan.dart';
import 'simulated_bike.dart';

final class SimulatorSource implements TelemetrySource {
  static const int firmwareVersion = 0x00010000;
  static const int healthySignals = 0x03;

  static const Duration statusInterval = Duration(seconds: 1);
  static const Duration telemetryInterval = Duration(milliseconds: 50);

  final FaultPlan faults = FaultPlan();

  final FrameDecoder _commands = FrameDecoder();

  final Random _random;

  final SimulatedBike bike;

  final Stopwatch _bootClock = Stopwatch();

  late final StreamController<List<int>> _bytes = StreamController.broadcast(onListen: _start, onCancel: _stop);

  int _sequence = 0;

  Duration _sinceStatus = Duration.zero;

  Duration? _unpluggedUntil;

  Timer? _timer;

  SimulatorSource({required this.bike, Random? random}) : _random = random ?? Random();

  void rebootBim() {
    _sequence = 0;
    _bootClock.reset();
  }

  void unplug(Duration duration) {
    final frame = Frame(message: bike.toMessage(), sequence: _sequence, timestampMs: _bootClock.elapsedMilliseconds).encode();
    _bytes.add(frame.sublist(0, frame.length ~/ 2));
    _unpluggedUntil = _bootClock.elapsed + duration;
  }

  void tick(Duration elapsed) {
    bike.advance(elapsed);
    final unpluggedUntil = _unpluggedUntil;
    if (unpluggedUntil != null) {
      if (_bootClock.elapsed < unpluggedUntil) return;
      _unpluggedUntil = null;
    }
    if (faults.dropout) return;
    _emit(_telemetryMessage());
    _sinceStatus += elapsed;
    if (_sinceStatus < statusInterval) return;
    _sinceStatus = Duration.zero;
    _emit(StatusMessage(bikeMv: bike.batteryMv.round() + _random.nextInt(200) - 100, firmwareVersion: firmwareVersion, signalHealth: healthySignals));
  }

  void _start() {
    _bootClock.start();
    _timer = Timer.periodic(telemetryInterval, (_) => tick(telemetryInterval));
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  TelemetryMessage _telemetryMessage() {
    final message = bike.toMessage();
    final spike = _random.nextDouble() < faults.spikeRate ? 600 : 0;
    final slosh = faults.fuelSlosh ? _random.nextInt(161) - 80 : 0;
    if (spike == 0 && slosh == 0) return message;
    return TelemetryMessage(
      flags: message.flags,
      fuelPercentX10: (message.fuelPercentX10 + slosh).clamp(0, 1000),
      fuelRawMv: message.fuelRawMv,
      odometerM: message.odometerM,
      speedKmhX10: message.speedKmhX10 + spike,
      tripAM: message.tripAM,
      tripBM: message.tripBM,
    );
  }

  void _emit(ProtocolMessage message) {
    final bytes = Frame(message: message, sequence: _sequence, timestampMs: _bootClock.elapsedMilliseconds).encode();
    _sequence = (_sequence + 1) & 0xFFFF;
    if (_random.nextDouble() < faults.crcErrorRate) bytes[bytes.length - 1] ^= 0xFF;
    final delay = faults.delay + faults.jitter * _random.nextDouble();
    if (delay == Duration.zero) {
      _bytes.add(bytes);
      return;
    }
    Timer(delay, () {
      if (!_bytes.isClosed) _bytes.add(bytes);
    });
  }

  @override
  Stream<List<int>> get bytes => _bytes.stream;

  @override
  Future<void> close() async {
    _stop();
    await _bytes.close();
  }

  @override
  Future<void> send(List<int> bytes) async {
    for (final event in _commands.add(bytes)) {
      if (event is! FrameDecoded) continue;
      switch (event.frame.message) {
        case SetOdometerMessage(:final odometerM):
          bike.odometerM = odometerM.toDouble();
        case ResetTripMessage(:final tripId):
          bike.resetTrip(tripId);
        case PingMessage():
          _emit(const AckMessage(code: 0));
        default:
          break;
      }
    }
  }
}
