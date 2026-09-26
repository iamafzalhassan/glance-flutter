import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../../core/config/app_config.dart';
import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/device_providers.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../../../core/providers/vehicle_providers.dart';
import '../widgets/setting_row.dart';

class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final firmware = ref.watch(telemetryProvider.select((snapshot) => snapshot.firmwareVersion));
    final vehicle = ref.watch(vehicleProfileProvider).value?.name;
    final valueStyle = NightRoadType.body.copyWith(color: colors.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingRow(
          label: GlanceCopy.appVersion,
          trailing: Text(AppConfig.version, maxLines: 1, overflow: TextOverflow.ellipsis, style: valueStyle),
        ),
        SettingRow(
          label: GlanceCopy.firmware,
          trailing: Text(firmware == null ? GlanceCopy.noSignal : GlanceCopy.firmwareVersion(firmware), maxLines: 1, overflow: TextOverflow.ellipsis, style: valueStyle),
        ),
        SettingRow(
          label: GlanceCopy.vehicle,
          trailing: Text(vehicle ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: valueStyle),
        ),
        const Spacer(),
        Text(
          GlanceCopy.exitKioskBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: NightRoadType.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: NightRoadSpacing.md),
        SizedBox(
          width: double.infinity,
          child: NightRoadButton(color: colors.stateDanger, label: GlanceCopy.exitKiosk, onPressed: ref.read(deviceControlProvider).exitKiosk),
        ),
      ],
    );
  }
}
