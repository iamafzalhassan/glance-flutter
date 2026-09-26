import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glance/app.dart';
import 'package:glance/core/device/no_device_control.dart';
import 'package:glance/core/providers/device_providers.dart';
import 'package:glance/core/providers/telemetry_providers.dart';
import 'package:glance/features/hmi/hmi_root.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  const highwayKmh = 88.0;
  const frameBudgetMs = 16;
  const reportKey = 'highway';
  const sampleFrames = 600;
  const frameInterval = Duration(milliseconds: 16);
  const bootWait = Duration(seconds: 2);
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a highway ride holds the 16 ms frame budget', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [deviceControlProvider.overrideWithValue(const NoDeviceControl())], child: const GlanceApp()));
    await tester.pump(bootWait);
    ProviderScope.containerOf(tester.element(find.byType(HmiRoot))).read(simulatorProvider).bike.targetSpeedKmh = highwayKmh;
    await binding.watchPerformance(() async {
      for (var frame = 0; frame < sampleFrames; frame++) {
        await tester.pump(frameInterval);
      }
    }, reportKey: reportKey);
    final report = binding.reportData![reportKey] as Map<String, dynamic>;
    expect(report['99th_percentile_frame_build_time_millis'] as num, lessThan(frameBudgetMs));
    expect(report['99th_percentile_frame_rasterizer_time_millis'] as num, lessThan(frameBudgetMs));
  });
}
