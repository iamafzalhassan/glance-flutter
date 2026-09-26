import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:glance_protocol/glance_protocol.dart';

import 'freshness.dart';
import 'link_stats.dart';
import 'reading.dart';
import 'telemetry_policy.dart';
import 'telemetry_snapshot.dart';
import 'telemetry_source.dart';

Duration Function() _monotonicClock() {
  final watch = Stopwatch()..start();
  return () => watch.elapsed;
}

final class TelemetryHub {
  static const int delayResetMs = 5000;
  static const int rebootDropMs = 1000;

  static const Duration rateWindow = Duration(seconds: 1);

  final Map<FrameRejection, int> _rejected = {};

  final Duration Function() _now;

  final FrameDecoder _decoder = FrameDecoder();

  final ListQueue<Duration> _acceptedAt = ListQueue();

  final SequenceGate _gate = SequenceGate();

  final StreamController<TelemetrySnapshot> _snapshots = StreamController.broadcast();

  final TelemetryPolicy policy;

  bool _ridingLocked = false;

  int _delayMs = 0;
  int _lastFrameTimestampMs = 0;
  int _lastTelemetryTimestampMs = 0;
  int _outOfOrderFrames = 0;
  int _spikeFrames = 0;
  int _txSequence = 0;

  TelemetrySnapshot _current = TelemetrySnapshot.initial;

  int? _minTransitMs;

  Duration? _slowSince;
  Duration? _statusAt;
  Duration? _telemetryAt;

  StatusMessage? _status;

  StreamSubscription<List<int>>? _subscription;

  TelemetryMessage? _telemetry;

  TelemetrySource? _source;

  Timer? _ticker;

  TelemetryHub({this.policy = TelemetryPolicy.standard, Duration Function()? now}) : _now = now ?? _monotonicClock();

  Stream<TelemetrySnapshot> get snapshots => _snapshots.stream;

  TelemetrySnapshot get current => _current;

  void attach(TelemetrySource source) {
    detach();
    _source = source;
    _subscription = source.bytes.listen(receive, onError: (Object _) {});
    _ticker = Timer.periodic(policy.tick, (_) => refresh());
  }

  void receive(List<int> chunk) {
    final receivedAt = _now();
    for (final event in _decoder.add(chunk)) {
      switch (event) {
        case FrameRejected(:final reason):
          _rejected[reason] = (_rejected[reason] ?? 0) + 1;
        case FrameDecoded(:final frame):
          _accept(frame, receivedAt);
      }
    }
    refresh();
  }

  void refresh() {
    _current = _resolve(_now());
    if (!_snapshots.isClosed) _snapshots.add(_current);
  }

  Future<void> dispose() async {
    detach();
    await _snapshots.close();
  }

  void detach() {
    _subscription?.cancel();
    _subscription = null;
    _ticker?.cancel();
    _ticker = null;
    _source = null;
    _decoder.reset();
    _gate.reset();
    _lastFrameTimestampMs = 0;
  }

  Future<void> send(ProtocolMessage message) async {
    final source = _source;
    if (source == null) return;
    final frame = Frame(message: message, sequence: _txSequence, timestampMs: _now().inMilliseconds);
    _txSequence = (_txSequence + 1) & 0xFFFF;
    await source.send(frame.encode());
  }

  void _accept(Frame frame, Duration receivedAt) {
    if (_lastFrameTimestampMs - frame.timestampMs > rebootDropMs) _gate.reset();
    if (!_gate.accept(frame.sequence)) {
      _outOfOrderFrames++;
      return;
    }
    _lastFrameTimestampMs = frame.timestampMs;
    final accepted = switch (frame.message) {
      final TelemetryMessage message => _acceptTelemetry(message, frame.timestampMs, receivedAt),
      final StatusMessage message => _acceptStatus(message, receivedAt),
      _ => true,
    };
    if (!accepted) return;
    _trackDelay(frame.timestampMs, receivedAt);
  }

  bool _acceptTelemetry(TelemetryMessage message, int timestampMs, Duration receivedAt) {
    if (_isSpike(message, timestampMs, receivedAt)) {
      _spikeFrames++;
      return false;
    }
    _telemetry = message;
    _telemetryAt = receivedAt;
    _lastTelemetryTimestampMs = timestampMs;
    _acceptedAt.addLast(receivedAt);
    return true;
  }

  bool _isSpike(TelemetryMessage message, int timestampMs, Duration receivedAt) {
    final previous = _telemetry;
    final previousAt = _telemetryAt;
    if (previous == null || previousAt == null || receivedAt - previousAt > policy.linkStaleAfter) return false;
    final elapsedMs = max(100, (timestampMs - _lastTelemetryTimestampMs) & 0xFFFFFFFF);
    final stepKmh = (message.speedKmhX10 - previous.speedKmhX10).abs() / 10;
    return stepKmh > policy.spikeKmhPer100Ms * elapsedMs / 100;
  }

  bool _acceptStatus(StatusMessage message, Duration receivedAt) {
    _status = message;
    _statusAt = receivedAt;
    return true;
  }

  void _trackDelay(int timestampMs, Duration receivedAt) {
    final transitMs = receivedAt.inMilliseconds - timestampMs;
    final minTransitMs = _minTransitMs;
    if (minTransitMs == null || transitMs < minTransitMs || transitMs - minTransitMs > delayResetMs) _minTransitMs = transitMs;
    _delayMs = transitMs - _minTransitMs!;
  }

  TelemetrySnapshot _resolve(Duration now) {
    while (_acceptedAt.isNotEmpty && now - _acceptedAt.first > rateWindow) {
      _acceptedAt.removeFirst();
    }
    final telemetry = _telemetry;
    final status = _status;
    final linkFreshness = _freshness(now, _telemetryAt, policy.linkStaleAfter);
    final fuelFreshness = _degrade(_freshness(now, _telemetryAt, policy.fuelStaleAfter), telemetry?.has(TelemetryFlag.fuelSignalOk) ?? false);
    final odometerFreshness = _freshness(now, _telemetryAt, policy.odometerStaleAfter);
    final speedKmh = telemetry == null ? null : telemetry.speedKmhX10 / 10;
    return TelemetrySnapshot(
      bikeMv: Reading(freshness: _freshness(now, _statusAt, policy.statusStaleAfter), value: status?.bikeMv),
      firmwareVersion: status?.firmwareVersion,
      flags: Reading(freshness: linkFreshness, value: telemetry?.flags),
      fuelPercent: Reading(freshness: fuelFreshness, value: telemetry == null ? null : telemetry.fuelPercentX10 / 10),
      fuelRawMv: Reading(freshness: fuelFreshness, value: telemetry?.fuelRawMv),
      linkUp: linkFreshness == Freshness.live,
      odometerM: Reading(freshness: odometerFreshness, value: telemetry?.odometerM),
      ridingLocked: _updateRidingLock(now, speedKmh ?? 0),
      speedKmh: Reading(freshness: _degrade(linkFreshness, telemetry?.has(TelemetryFlag.speedSignalOk) ?? false), value: speedKmh),
      stats: LinkStats(delayMs: _delayMs, framesPerSecond: _acceptedAt.length, outOfOrderFrames: _outOfOrderFrames, rejectedFrames: Map.unmodifiable(_rejected), spikeFrames: _spikeFrames),
      tripAM: Reading(freshness: odometerFreshness, value: telemetry?.tripAM),
      tripBM: Reading(freshness: odometerFreshness, value: telemetry?.tripBM),
    );
  }

  Freshness _freshness(Duration now, Duration? receivedAt, Duration staleAfter) {
    if (receivedAt == null) return Freshness.missing;
    return now - receivedAt > staleAfter ? Freshness.stale : Freshness.live;
  }

  bool _updateRidingLock(Duration now, double speedKmh) {
    if (speedKmh > policy.ridingLockAboveKmh) {
      _ridingLocked = true;
      _slowSince = null;
      return true;
    }
    if (!_ridingLocked) return false;
    final slowSince = _slowSince ??= now;
    if (now - slowSince < policy.unlockAfter) return true;
    _ridingLocked = false;
    _slowSince = null;
    return false;
  }

  Freshness _degrade(Freshness freshness, bool signalOk) => freshness == Freshness.live && !signalOk ? Freshness.stale : freshness;
}
