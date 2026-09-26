import 'package:flutter_test/flutter_test.dart';
import 'package:glance/features/navigation/arrival_watch.dart';

void main() {
  const near = ArrivalWatch.arrivedWithinM;

  late ArrivalWatch watch;

  setUp(() => watch = ArrivalWatch());

  test('arrives once the rider comes within the arrival distance', () {
    expect(watch.hasArrived(5000), isFalse);
    expect(watch.hasArrived(near + 1), isFalse);
    expect(watch.hasArrived(near), isTrue);
  });

  test('never arrives at once when the ride starts at the destination', () {
    expect(watch.hasArrived(0), isFalse);
    expect(watch.hasArrived(near), isFalse);
  });

  test('arrives after starting close and riding away first', () {
    expect(watch.hasArrived(10), isFalse);
    expect(watch.hasArrived(near + 1), isFalse);
    expect(watch.hasArrived(0), isTrue);
  });
}
