import 'package:flutter_test/flutter_test.dart';
import 'package:glance_maps/glance_maps.dart';

void main() {
  test('decodes the example from the Google polyline documentation', () {
    final points = PolylineCodec.decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(points, hasLength(3));
    expect(points[0].latitude, closeTo(38.5, 1e-5));
    expect(points[0].longitude, closeTo(-120.2, 1e-5));
    expect(points[1].latitude, closeTo(40.7, 1e-5));
    expect(points[1].longitude, closeTo(-120.95, 1e-5));
    expect(points[2].latitude, closeTo(43.252, 1e-5));
    expect(points[2].longitude, closeTo(-126.453, 1e-5));
  });

  test('decodes an empty polyline to no points', () => expect(PolylineCodec.decode(''), isEmpty));
}
