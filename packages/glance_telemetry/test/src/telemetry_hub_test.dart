import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:test/test.dart';

void main() {
  late FakeClock clock;
  late TelemetryHub hub;
  var sequence = 0;

  List<int> telemetryFrame({double speedKmh = 42.3, double fuelPercent = 62, int timestampMs = 0, Set<TelemetryFlag> flags = const {TelemetryFlag.ignition, TelemetryFlag.speedSignalOk, TelemetryFlag.fuelSignalOk}, int? frameSequence}) =>
      Frame(
        message: TelemetryMessage(flags: TelemetryFlag.pack(flags), fuelPercentX10: (fuelPercent * 10).round(), fuelRawMv: 1450, odometerM: 18420000, speedKmhX10: (speedKmh * 10).round(), tripAM: 36400, tripBM: 1200),
        sequence: frameSequence ?? sequence++,
        timestampMs: timestampMs,
      ).encode();

  setUp(() {
    clock = FakeClock();
    hub = TelemetryHub(now: clock.call);
    sequence = 0;
  });

  tearDown(() => hub.dispose());

  test('reports every reading as missing before the first frame', () {
    hub.refresh();
    expect(hub.current.linkUp, isFalse);
    expect(hub.current.speedKmh.freshness, Freshness.missing);
    expect(hub.current.fuelPercent.freshness, Freshness.missing);
  });

  test('shows live speed from a valid frame', () {
    hub.receive(telemetryFrame());
    expect(hub.current.linkUp, isTrue);
    expect(hub.current.speedKmh.liveValue, 42.3);
  });

  test('drops speed to stale within 500 ms of silence and keeps the last value out of the live view', () {
    hub.receive(telemetryFrame());
    clock.advance(const Duration(milliseconds: 499));
    hub.refresh();
    expect(hub.current.speedKmh.isLive, isTrue);
    clock.advance(const Duration(milliseconds: 2));
    hub.refresh();
    expect(hub.current.linkUp, isFalse);
    expect(hub.current.speedKmh.freshness, Freshness.stale);
    expect(hub.current.speedKmh.liveValue, isNull);
  });

  test('greys fuel as last known only after its own, longer timer', () {
    hub.receive(telemetryFrame(fuelPercent: 55));
    clock.advance(const Duration(milliseconds: 600));
    hub.refresh();
    expect(hub.current.fuelPercent.isLive, isTrue);
    clock.advance(const Duration(seconds: 3));
    hub.refresh();
    expect(hub.current.fuelPercent.freshness, Freshness.stale);
    expect(hub.current.fuelPercent.value, 55);
  });

  test('treats speed as stale when the BIM reports a bad speed signal', () {
    hub.receive(telemetryFrame(flags: const {TelemetryFlag.ignition, TelemetryFlag.fuelSignalOk}));
    expect(hub.current.linkUp, isTrue);
    expect(hub.current.speedKmh.freshness, Freshness.stale);
    expect(hub.current.fuelPercent.isLive, isTrue);
  });

  test('rejects a speed spike and keeps the previous speed', () {
    hub.receive(telemetryFrame(speedKmh: 30));
    clock.advance(const Duration(milliseconds: 50));
    hub.receive(telemetryFrame(speedKmh: 90, timestampMs: 50));
    expect(hub.current.stats.spikeFrames, 1);
    expect(hub.current.speedKmh.liveValue, 30);
  });

  test('accepts a large change that is physically possible over the elapsed time', () {
    hub.receive(telemetryFrame(speedKmh: 0));
    clock.advance(const Duration(milliseconds: 200));
    hub.receive(telemetryFrame(speedKmh: 60, timestampMs: 200));
    expect(hub.current.stats.spikeFrames, 0);
    expect(hub.current.speedKmh.liveValue, 60);
  });

  test('rejects an out-of-order frame', () {
    hub.receive(telemetryFrame(frameSequence: 5, speedKmh: 20));
    hub.receive(telemetryFrame(frameSequence: 4, speedKmh: 21));
    expect(hub.current.stats.outOfOrderFrames, 1);
    expect(hub.current.speedKmh.liveValue, 20);
  });

  test('accepts frames at once after a BIM reboot restarts the sequence and clock', () {
    hub.receive(telemetryFrame(frameSequence: 1000, speedKmh: 20, timestampMs: 600000));
    clock.advance(const Duration(milliseconds: 50));
    hub.receive(telemetryFrame(frameSequence: 0, speedKmh: 21, timestampMs: 300));
    expect(hub.current.stats.outOfOrderFrames, 0);
    expect(hub.current.speedKmh.liveValue, 21);
  });

  test('counts a corrupted frame and never shows its data', () {
    final corrupted = telemetryFrame(speedKmh: 50);
    corrupted[corrupted.length - 1] ^= 0xFF;
    hub.receive(corrupted);
    expect(hub.current.stats.rejectedFor(FrameRejection.badCrc), 1);
    expect(hub.current.speedKmh.freshness, Freshness.missing);
  });

  test('locks riding-only controls above 5 km/h', () {
    hub.receive(telemetryFrame(speedKmh: 4));
    expect(hub.current.ridingLocked, isFalse);
    hub.receive(telemetryFrame(speedKmh: 6, timestampMs: 100));
    expect(hub.current.ridingLocked, isTrue);
  });

  test('recovers after a cable pull leaves half a frame behind', () {
    final frame = telemetryFrame(speedKmh: 30);
    hub.receive(frame.sublist(0, frame.length ~/ 2));
    hub.receive(telemetryFrame(speedKmh: 31));
    expect(hub.current.speedKmh.liveValue, 31);
    expect(hub.current.stats.discardedFrames, lessThanOrEqualTo(1));
  });

  test('keeps parked-only controls locked for 3 s after slowing down, then unlocks', () {
    hub.receive(telemetryFrame(speedKmh: 20));
    clock.advance(const Duration(milliseconds: 100));
    hub.receive(telemetryFrame(speedKmh: 3, timestampMs: 1000));
    expect(hub.current.ridingLocked, isTrue);
    clock.advance(const Duration(seconds: 2));
    hub.receive(telemetryFrame(speedKmh: 0, timestampMs: 3000));
    expect(hub.current.ridingLocked, isTrue);
    clock.advance(const Duration(milliseconds: 1100));
    hub.receive(telemetryFrame(speedKmh: 0, timestampMs: 4100));
    expect(hub.current.ridingLocked, isFalse);
  });

  test('locks again the moment speed passes 5 km/h', () {
    hub.receive(telemetryFrame(speedKmh: 2));
    expect(hub.current.ridingLocked, isFalse);
    hub.receive(telemetryFrame(speedKmh: 5.5, timestampMs: 100));
    expect(hub.current.ridingLocked, isTrue);
  });

  test('keeps the lock on the last known speed when the signal is lost at speed', () {
    hub.receive(telemetryFrame(speedKmh: 40));
    clock.advance(const Duration(seconds: 2));
    hub.refresh();
    expect(hub.current.linkUp, isFalse);
    expect(hub.current.ridingLocked, isTrue);
  });
}

final class FakeClock {
  Duration _now = Duration.zero;

  void advance(Duration duration) => _now += duration;

  Duration call() => _now;
}
