import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/vehicle/fuel_range_learner.dart';

void main() {
  late FuelRangeLearner learner;

  setUp(() => learner = FuelRangeLearner());

  test('learns percent per km once enough distance and fuel have gone', () {
    expect(learner.learn(fuelPercent: 80, learned: 0, odometerM: 100000), 0);
    expect(learner.learn(fuelPercent: 78, learned: 0, odometerM: 110000), 0);
    expect(learner.learn(fuelPercent: 72, learned: 0, odometerM: 120000), closeTo(0.4, 0.0001));
  });

  test('blends a new sample into what it already learned', () {
    learner.learn(fuelPercent: 80, learned: 0.4, odometerM: 0);
    expect(learner.learn(fuelPercent: 68, learned: 0.4, odometerM: 20000), closeTo(0.4 + (0.6 - 0.4) * FuelRangeLearner.newWeight, 0.0001));
  });

  test('starts over after a refuel instead of learning a negative rate', () {
    learner.learn(fuelPercent: 30, learned: 0.4, odometerM: 0);
    expect(learner.learn(fuelPercent: 95, learned: 0.4, odometerM: 25000), 0.4);
    expect(learner.learn(fuelPercent: 87, learned: 0.4, odometerM: 45000), closeTo(0.4, 0.0001));
  });

  test('gives no range until something is learned, then rounds to 10 km', () {
    expect(FuelRangeLearner.rangeKm(62, 0), isNull);
    expect(FuelRangeLearner.rangeKm(62, 0.4), 160);
  });
}
