import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/layout/text_measure.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/providers/telemetry_providers.dart';

class SpeedBlock extends ConsumerWidget {
  const SpeedBlock({super.key});

  static const String _widestReading = '888';

  static Size naturalSize(TextScaler textScaler) {
    final numeral = TextMeasure.of(_widestReading, NightRoadType.numSpeed, textScaler: textScaler);
    final unit = TextMeasure.of(GlanceCopy.kmh, NightRoadType.caption, textScaler: textScaler);
    return Size(max(numeral.width, unit.width), numeral.height + unit.height);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(telemetryProvider.select((snapshot) => snapshot.speedKmh.liveValue?.round()));
    final alertKmh = ref.watch(settingsProvider.select((settings) => settings.speedAlertKmh));
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const Visibility.maintain(visible: false, child: Text(_widestReading, maxLines: 1, style: NightRoadType.numSpeed)),
            AnimatedSwitcher(
              duration: NightRoadMotion.of(context, NightRoadMotion.instant),
              switchInCurve: NightRoadMotion.instantCurve,
              switchOutCurve: NightRoadMotion.instantCurve,
              child: speed == null
                  ? const SizedBox.shrink()
                  : Text(
                      speed.toString(),
                      key: ValueKey(speed),
                      maxLines: 1,
                      style: NightRoadType.numSpeed.copyWith(color: alertKmh > 0 && speed > alertKmh ? colors.stateWarn : colors.textPrimary),
                    ),
            ),
          ],
        ),
        Visibility.maintain(
          visible: speed != null,
          child: Text(GlanceCopy.kmh, maxLines: 1, style: NightRoadType.caption.copyWith(color: colors.textMuted)),
        ),
      ],
    );
  }
}
