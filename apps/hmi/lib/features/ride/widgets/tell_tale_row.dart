import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:night_road/night_road.dart';

import '../../../core/providers/telemetry_providers.dart';
import '../../../core/providers/vehicle_providers.dart';
import 'tell_tale_icon.dart';

class TellTaleRow extends ConsumerWidget {
  const TellTaleRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(vehicleProfileProvider).value;
    final flags = ref.watch(telemetryProvider.select((snapshot) => snapshot.flags.liveValue ?? 0));
    final colors = context.colors;
    bool isOn(TelemetryFlag flag, bool? fitted) => (fitted ?? false) && flags & flag.mask != 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: NightRoadSpacing.lg,
      children: [
        _TellTaleSlot(active: isOn(TelemetryFlag.left, profile?.leftIndicator), color: colors.stateIndicator, kind: TellTale.left),
        _TellTaleSlot(active: isOn(TelemetryFlag.highBeam, profile?.highBeam), color: colors.stateHighBeam, kind: TellTale.highBeam),
        _TellTaleSlot(active: isOn(TelemetryFlag.fiWarning, profile?.fiWarning), color: colors.stateDanger, kind: TellTale.engine),
        _TellTaleSlot(active: isOn(TelemetryFlag.sideStand, profile?.sideStand), color: colors.stateWarn, kind: TellTale.sideStand),
        _TellTaleSlot(active: isOn(TelemetryFlag.right, profile?.rightIndicator), color: colors.stateIndicator, kind: TellTale.right),
      ],
    );
  }
}

class _TellTaleSlot extends StatelessWidget {
  const _TellTaleSlot({required this.active, required this.color, required this.kind});

  final bool active;

  final Color color;

  final TellTale kind;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    curve: NightRoadMotion.quickCurve,
    duration: NightRoadMotion.of(context, NightRoadMotion.quick),
    opacity: active ? 1 : 0,
    child: TellTaleIcon(color: color, kind: kind),
  );
}
