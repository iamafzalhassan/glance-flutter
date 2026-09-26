import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/copy/glance_copy.dart';
import '../ride/widgets/tell_tale_icon.dart';
import 'critical_alert.dart';

class AlertLayer extends ConsumerWidget {
  const AlertLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(criticalAlertProvider);
    return AnimatedSwitcher(
      duration: NightRoadMotion.of(context, NightRoadMotion.standard),
      switchInCurve: NightRoadMotion.standardCurve,
      switchOutCurve: NightRoadMotion.standardCurve,
      child: alert == null ? const SizedBox.shrink() : _AlertSheet(key: ValueKey(alert), alert: alert, onDismiss: () => ref.read(dismissedAlertsProvider.notifier).dismiss(alert)),
    );
  }
}

class _AlertSheet extends StatelessWidget {
  const _AlertSheet({super.key, required this.alert, required this.onDismiss});

  static const double _scrimAlpha = 0.82;
  static const double _sheetWidth = 560;

  final CriticalAlert alert;

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = alert == CriticalAlert.engineWarning ? colors.stateDanger : colors.stateWarn;
    final title = alert == CriticalAlert.engineWarning ? GlanceCopy.engineWarning : GlanceCopy.lowFuel;
    final body = alert == CriticalAlert.engineWarning ? GlanceCopy.engineWarningBody : GlanceCopy.lowFuelBody;
    return ColoredBox(
      color: colors.bgBase.withValues(alpha: _scrimAlpha),
      child: Center(
        child: SizedBox(
          width: _sheetWidth,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: colors.bgPanel,
              shape: NightRoadRadius.panelShape.copyWith(
                side: BorderSide(color: accent, width: NightRoadSpacing.outline),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(NightRoadSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      alert == CriticalAlert.engineWarning ? TellTaleIcon(color: accent, kind: TellTale.engine, size: NightRoadSpacing.iconLarge) : Icon(Icons.local_gas_station_rounded, color: accent, size: NightRoadSpacing.iconLarge),
                      const SizedBox(width: NightRoadSpacing.lg),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NightRoadType.title.copyWith(color: colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NightRoadSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.body.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: NightRoadSpacing.xl),
                  NightRoadButton(color: accent, label: GlanceCopy.dismiss, onPressed: onDismiss),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
