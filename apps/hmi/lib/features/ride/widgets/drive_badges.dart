import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../../../core/providers/vehicle_providers.dart';

class DriveBadges extends ConsumerWidget {
  const DriveBadges({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(vehicleProfileProvider).value;
    final eco = (profile?.eco ?? false) && ref.watch(telemetryProvider.select((snapshot) => snapshot.has(TelemetryFlag.eco)));
    final noSignal = ref.watch(telemetryProvider.select((snapshot) => snapshot.speedKmh.liveValue == null));
    final stopStart = !(profile?.stopStart ?? false)
        ? StopStartMode.off
        : ref.watch(
            telemetryProvider.select((snapshot) {
              if (snapshot.has(TelemetryFlag.engineAutoStopped)) return StopStartMode.autoStopped;
              return snapshot.has(TelemetryFlag.stopStartEnabled) ? StopStartMode.enabled : StopStartMode.off;
            }),
          );
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChipSlot(
          child: noSignal ? NightRoadPill(key: const ValueKey(GlanceCopy.noSignal), color: colors.stateDanger, label: GlanceCopy.noSignal) : null,
        ),
        _ChipSlot(
          child: eco ? NightRoadPill(key: const ValueKey(GlanceCopy.eco), color: colors.stateEco, label: GlanceCopy.eco) : null,
        ),
        _ChipSlot(
          child: switch (stopStart) {
            StopStartMode.off => null,
            StopStartMode.enabled => NightRoadPill(key: const ValueKey(StopStartMode.enabled), color: colors.textSecondary, label: GlanceCopy.stopStart),
            StopStartMode.autoStopped => NightRoadPill(key: const ValueKey(StopStartMode.autoStopped), color: colors.stateEco, filled: true, label: GlanceCopy.autoStop),
          },
        ),
      ],
    );
  }
}

class _ChipSlot extends StatelessWidget {
  const _ChipSlot({required this.child});

  final Widget? child;

  Widget _transition(Widget child, Animation<double> animation) => FadeTransition(
    opacity: animation,
    child: SizeTransition(axis: Axis.horizontal, fixedCrossAxisSizeFactor: 1, sizeFactor: animation, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final chip = child;
    return AnimatedSwitcher(
      duration: NightRoadMotion.of(context, NightRoadMotion.standard),
      switchInCurve: NightRoadMotion.standardCurve,
      switchOutCurve: NightRoadMotion.standardCurve,
      transitionBuilder: _transition,
      child: chip == null
          ? const SizedBox.shrink()
          : Padding(
              key: chip.key,
              padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.xs),
              child: chip,
            ),
    );
  }
}
