import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:glance/features/ride/widgets/speed_gauge_geometry.dart';

void main() {
  const labelHeight = 19.0;
  const labelWidthPerDigit = 10.0;
  const readoutSize = Size(300, 190);

  SpeedGaugeGeometry resolve(double side, double maxKmh) => SpeedGaugeGeometry.resolve(labelSize: (text) => Size(text.length * labelWidthPerDigit, labelHeight), maxKmh: maxKmh, readoutSize: readoutSize, size: Size.square(side));

  for (final side in const [240.0, 344.0, 480.0]) {
    for (final maxKmh in const [60.0, 100.0, 120.0, 140.0]) {
      group('a $side dp gauge up to $maxKmh km/h', () {
        late SpeedGaugeGeometry geometry;

        setUp(() => geometry = resolve(side, maxKmh));

        test('keeps the speed readout clear of every scale label', () {
          for (final label in geometry.labels) {
            expect(label.rect.inflate(SpeedGaugeGeometry.clearance).overlaps(geometry.readout), isFalse, reason: 'label ${label.text}');
          }
        });

        test('keeps the speed readout inside the ticks', () {
          final readout = geometry.readout;
          for (final corner in [readout.topLeft, readout.topRight, readout.bottomLeft, readout.bottomRight]) {
            expect((corner - geometry.centre).distance, lessThanOrEqualTo(geometry.clearRadius));
          }
        });

        test('keeps the chips below the readout, the labels and the arc', () {
          expect(geometry.readout.bottom, lessThanOrEqualTo(geometry.chin.top));
          for (final label in geometry.labels) {
            expect(label.rect.bottom, lessThan(geometry.chin.top));
          }
          expect(geometry.chin.top, greaterThan(geometry.centre.dy + geometry.radius / 2));
        });

        test('gives the readout real room in the proportions of the widest speed', () {
          final readout = geometry.readout;
          expect(readout.width, greaterThan(side / 4));
          expect(readout.width, lessThanOrEqualTo(readoutSize.width));
          expect(readout.width / readout.height, closeTo(readoutSize.aspectRatio, 0.001));
        });
      });
    }
  }

  test('labels every 20 km/h and ticks every 10 km/h', () {
    final geometry = resolve(344, 100);
    expect(geometry.labels.map((label) => label.text), ['0', '20', '40', '60', '80', '100']);
    expect(geometry.ticks, hasLength(11));
  });

  test('still places the readout when the top speed is not known', () {
    final geometry = resolve(344, 0);
    expect(geometry.labels, isEmpty);
    expect(geometry.ticks, isEmpty);
    expect(geometry.readout.width, greaterThan(0));
  });
}
