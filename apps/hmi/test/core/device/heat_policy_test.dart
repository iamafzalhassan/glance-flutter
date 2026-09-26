import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/device/device_heat.dart';
import 'package:glance/core/device/heat_policy.dart';

void main() {
  const policy = HeatPolicy.standard;

  test('turns hot above the upper threshold', () => expect(policy.isHot(const DeviceHeat(batteryCelsius: 46, thermalStatus: 0), wasHot: false), isTrue));

  test('stays cool between the thresholds when it was cool', () => expect(policy.isHot(const DeviceHeat(batteryCelsius: 43, thermalStatus: 0), wasHot: false), isFalse));

  test('stays hot between the thresholds when it was hot', () => expect(policy.isHot(const DeviceHeat(batteryCelsius: 43, thermalStatus: 0), wasHot: true), isTrue));

  test('cools below the lower threshold', () => expect(policy.isHot(const DeviceHeat(batteryCelsius: 40, thermalStatus: 0), wasHot: true), isFalse));

  test('trusts a severe Android thermal status over the battery reading', () => expect(policy.isHot(const DeviceHeat(batteryCelsius: 30, thermalStatus: 3), wasHot: false), isTrue));
}
