import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/providers/vehicle_providers.dart';
import '../../../core/settings/glance_settings.dart';
import '../widgets/setting_row.dart';

class DisplaySection extends ConsumerWidget {
  const DisplaySection({super.key});

  static const double _maxFloor = 0.8;
  static const double _minFloor = 0.1;

  static const int _alertStepKmh = 10;
  static const int _floorSteps = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final colors = context.colors;
    final maxKmh = ref.watch(vehicleProfileProvider).value?.maxDisplayKmh?.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NightRoadLabel(GlanceCopy.theme),
        const SizedBox(height: NightRoadSpacing.sm),
        Row(
          spacing: NightRoadSpacing.sm,
          children: [
            for (final preference in ThemePreference.values)
              NightRoadChoice(
                label: GlanceCopy.themePreference(preference),
                onSelected: () => notifier.update(settings.copyWith(theme: preference)),
                selected: settings.theme == preference,
              ),
          ],
        ),
        const SizedBox(height: NightRoadSpacing.xl),
        const NightRoadLabel(GlanceCopy.brightnessFloor),
        const SizedBox(height: NightRoadSpacing.sm),
        NightRoadSlider(
          divisions: _floorSteps,
          label: (value) => GlanceCopy.percent((value * 100).round()),
          max: _maxFloor,
          min: _minFloor,
          onChanged: (value) => notifier.update(settings.copyWith(brightnessFloor: value)),
          value: settings.brightnessFloor,
        ),
        if (maxKmh != null && maxKmh >= _alertStepKmh) ...[
          const SizedBox(height: NightRoadSpacing.lg),
          const NightRoadLabel(GlanceCopy.speedAlert),
          const SizedBox(height: NightRoadSpacing.sm),
          NightRoadSlider(
            divisions: maxKmh ~/ _alertStepKmh,
            label: (value) => value == 0 ? GlanceCopy.off : '${value.round()}',
            max: (maxKmh ~/ _alertStepKmh * _alertStepKmh).toDouble(),
            onChanged: (value) => notifier.update(settings.copyWith(speedAlertKmh: value.round())),
            value: settings.speedAlertKmh.toDouble(),
          ),
        ],
        const SizedBox(height: NightRoadSpacing.lg),
        SettingRow(
          label: GlanceCopy.reduceMotion,
          trailing: CupertinoSwitch(
            activeTrackColor: colors.stateEco,
            onChanged: (value) => notifier.update(settings.copyWith(reduceMotion: value)),
            value: settings.reduceMotion,
          ),
        ),
      ],
    );
  }
}
