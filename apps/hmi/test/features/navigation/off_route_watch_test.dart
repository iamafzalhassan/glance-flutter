import 'package:flutter_test/flutter_test.dart';
import 'package:glance/features/navigation/off_route_watch.dart';

void main() {
  const off = OffRouteWatch.offRouteM + 1;

  late OffRouteWatch watch;

  bool at(double offM, int seconds) => watch.shouldReroute(offM, Duration(seconds: seconds));

  setUp(() => watch = OffRouteWatch());

  test('reroutes only after several fixes in a row are off the route', () {
    expect(at(off, 0), isFalse);
    expect(at(off, 1), isFalse);
    expect(at(off, 2), isTrue);
  });

  test('a fix back on the route starts the count again', () {
    at(off, 0);
    at(off, 1);
    expect(at(0, 2), isFalse);
    expect(at(off, 3), isFalse);
    expect(at(off, 4), isFalse);
    expect(at(off, 5), isTrue);
  });

  test('never reroutes again sooner than the minimum interval', () {
    at(off, 0);
    at(off, 1);
    expect(at(off, 2), isTrue);
    expect(at(off, 3), isFalse);
    expect(at(off, 4), isFalse);
    expect(at(off, 5), isFalse);
    expect(at(off, 2 + OffRouteWatch.minInterval.inSeconds - 1), isFalse);
    expect(at(off, 2 + OffRouteWatch.minInterval.inSeconds), isTrue);
  });
}
