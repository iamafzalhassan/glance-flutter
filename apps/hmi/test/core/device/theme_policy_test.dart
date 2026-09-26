import 'package:flutter_test/flutter_test.dart';
import 'package:glance/core/device/theme_policy.dart';
import 'package:glance/core/providers/display_providers.dart';

void main() {
  const policy = ThemePolicy.standard;

  test('switches to day in bright light', () => expect(policy.next(2000, DisplayTheme.night), DisplayTheme.day));

  test('switches to night in the dark', () => expect(policy.next(100, DisplayTheme.day), DisplayTheme.night));

  test('keeps the current theme between the thresholds', () {
    expect(policy.next(800, DisplayTheme.day), DisplayTheme.day);
    expect(policy.next(800, DisplayTheme.night), DisplayTheme.night);
  });
}
