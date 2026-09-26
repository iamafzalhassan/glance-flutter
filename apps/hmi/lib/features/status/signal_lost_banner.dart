import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/copy/glance_copy.dart';
import '../../core/providers/telemetry_providers.dart';

class SignalLostBanner extends ConsumerWidget {
  const SignalLostBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkUp = ref.watch(telemetryProvider.select((snapshot) => snapshot.linkUp));
    final colors = context.colors;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: NightRoadMotion.of(context, NightRoadMotion.standard),
        switchInCurve: NightRoadMotion.standardCurve,
        switchOutCurve: NightRoadMotion.standardCurve,
        child: linkUp
            ? const SizedBox.shrink()
            : DecoratedBox(
                decoration: ShapeDecoration(color: colors.stateDanger, shape: NightRoadRadius.cardShape),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.moduleInset, vertical: NightRoadSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.link_off_rounded, color: colors.bgBase, size: NightRoadSpacing.icon),
                      const SizedBox(width: NightRoadSpacing.md),
                      Expanded(
                        child: Text(
                          GlanceCopy.noBikeSignalBody,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NightRoadType.title.copyWith(color: colors.bgBase),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
