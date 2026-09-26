import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/vehicle/battery_watch.dart';

void main() {
  const lowMv = 11800;

  late BatteryWatch watch;

  bool at(int millivolts, int seconds) => watch.update(
    lowMv: lowMv,
    millivolts: millivolts,
    now: Duration(seconds: seconds),
  );

  setUp(() => watch = BatteryWatch());

  test('ignores a short dip such as the starter cranking', () {
    expect(at(10500, 0), isFalse);
    expect(at(10500, 5), isFalse);
    expect(at(12600, 6), isFalse);
    expect(at(11500, 7), isFalse);
    expect(at(11500, 7 + BatteryWatch.holdFor.inSeconds - 1), isFalse);
  });

  test('reports low after the voltage stays below the threshold', () {
    expect(at(11500, 0), isFalse);
    expect(at(11500, BatteryWatch.holdFor.inSeconds), isTrue);
  });

  test('clears only once the voltage recovers past the margin', () {
    at(11500, 0);
    at(11500, BatteryWatch.holdFor.inSeconds);
    expect(at(lowMv + BatteryWatch.recoverMarginMv - 1, 40), isTrue);
    expect(at(lowMv + BatteryWatch.recoverMarginMv, 41), isFalse);
  });
}
