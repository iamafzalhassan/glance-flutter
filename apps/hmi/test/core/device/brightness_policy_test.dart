import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/device/brightness_policy.dart';

void main() {
  const policy = BrightnessPolicy.standard;

  test('never drops below the riding floor in the dark', () => expect(policy.ridingLevel(hot: false, lux: 1), policy.ridingFloor));

  test('reaches full brightness in direct sun', () => expect(policy.ridingLevel(hot: false, lux: 50000), closeTo(1, 1e-9)));

  test('rises with ambient light', () {
    final levels = [
      for (final lux in [50.0, 500.0, 5000.0]) policy.ridingLevel(hot: false, lux: lux),
    ];
    expect(levels[0] < levels[1] && levels[1] < levels[2], isTrue);
  });

  test('caps brightness while the tablet is too hot', () => expect(policy.ridingLevel(hot: true, lux: 50000), policy.heatCap));
}
