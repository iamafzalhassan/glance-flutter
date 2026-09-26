import 'package:glance_protocol/glance_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('accepts the first frame and every later sequence', () {
    final gate = SequenceGate();
    expect([gate.accept(5), gate.accept(6), gate.accept(9)], [true, true, true]);
  });

  test('rejects a duplicate and an older sequence', () {
    final gate = SequenceGate()..accept(100);
    expect([gate.accept(100), gate.accept(99), gate.accept(101)], [false, false, true]);
  });

  test('accepts the wrap from 65535 to 0', () {
    final gate = SequenceGate()..accept(0xFFFF);
    expect(gate.accept(0), isTrue);
  });

  test('resyncs after a run of rejects, as after a BIM reboot', () {
    final gate = SequenceGate()..accept(20000);
    final results = [for (var index = 0; index < SequenceGate.resyncAfter; index++) gate.accept(index)];
    expect(results.sublist(0, SequenceGate.resyncAfter - 1), everyElement(isFalse));
    expect(results.last, isTrue);
    expect(gate.accept(SequenceGate.resyncAfter), isTrue);
  });

  test('starts fresh after reset', () {
    final gate = SequenceGate()..accept(500);
    gate.reset();
    expect(gate.accept(3), isTrue);
  });
}
