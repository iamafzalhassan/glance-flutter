import 'package:flutter_test/flutter_test.dart';
import 'package:glance_maps/glance_maps.dart';

void main() {
  const start = GeoPoint(6.90, 79.85);
  const middle = GeoPoint(6.91, 79.85);
  const end = GeoPoint(6.91, 79.86);
  final path = RoutePath(const [start, middle, end]);

  test('starts at the first point with the whole route ahead', () {
    final at = path.at(0);
    expect(at.position, start);
    expect(at.ahead, [start, middle, end]);
  });

  test('ends at the last point', () => expect(path.at(1).position.distanceTo(end), lessThan(1)));

  test('drops the passed points from the route ahead', () {
    final at = path.at(0.75);
    expect(at.ahead.first, at.position);
    expect(at.ahead.last, end);
    expect(at.ahead, isNot(contains(start)));
  });

  test('heads north on the first leg and east on the second', () {
    expect(path.at(0.25).bearing, closeTo(0, 1));
    expect(path.at(0.9).bearing, closeTo(90, 1));
  });

  test('locates a point beside the route at its distance along and away from it', () {
    const beside = GeoPoint(6.905, 79.8501);
    final located = path.locate(beside);
    expect(located.alongM, closeTo(start.distanceTo(const GeoPoint(6.905, 79.85)), 1));
    expect(located.offM, closeTo(beside.distanceTo(const GeoPoint(6.905, 79.85)), 1));
  });

  test('locates a point on the second segment past the whole first one', () {
    final located = path.locate(const GeoPoint(6.91, 79.855));
    expect(located.alongM, closeTo(start.distanceTo(middle) + middle.distanceTo(const GeoPoint(6.91, 79.855)), 1));
    expect(located.offM, lessThan(1));
  });

  test('treats a single point as a fixed position', () => expect(RoutePath(const [start]).at(0.5).position, start));
}
