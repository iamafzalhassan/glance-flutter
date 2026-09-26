import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/copy/glance_copy.dart';
import '../../core/providers/vehicle_providers.dart';
import 'notice.dart';

class NoticeCard extends ConsumerWidget {
  const NoticeCard({super.key, required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (icon, title, body) = switch (notice) {
      Notice.batteryLow => (Icons.battery_alert_rounded, GlanceCopy.batteryLow, GlanceCopy.batteryLowBody),
      Notice.service => (Icons.build_rounded, GlanceCopy.serviceDue, GlanceCopy.serviceIn(ref.watch(serviceRemainingKmProvider) ?? 0)),
    };
    return SizedBox(
      width: NightRoadSpacing.overlayCard,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: colors.bgOverlay, shape: NightRoadRadius.cardShape),
        child: Padding(
          padding: const EdgeInsets.all(NightRoadSpacing.lg),
          child: Row(
            spacing: NightRoadSpacing.md,
            children: [
              Icon(icon, color: colors.stateWarn, size: NightRoadSpacing.iconLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.title.copyWith(color: colors.textPrimary),
                    ),
                    Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.body.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              NightRoadRoundButton(icon: Icons.close_rounded, onPressed: () => ref.read(dismissedNoticesProvider.notifier).dismiss(notice)),
            ],
          ),
        ),
      ),
    );
  }
}
