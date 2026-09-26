import 'package:flutter/material.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/format/glance_format.dart';
import '../../navigation/maneuver_icon.dart';
import '../../navigation/navigation_route.dart';

class TurnCard extends StatelessWidget {
  const TurnCard({super.key, required this.state, required this.onStop});

  final NavigationState state;

  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: NightRoadSpacing.overlayCard,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: colors.bgOverlay, shape: NightRoadRadius.cardShape),
        child: Padding(
          padding: const EdgeInsets.all(NightRoadSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(state.maneuver.icon, color: colors.accentNav, size: NightRoadSpacing.iconLarge),
                  const SizedBox(width: NightRoadSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          GlanceCopy.distance(state.distanceToTurnM),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NightRoadType.numLarge.copyWith(color: colors.textPrimary),
                        ),
                        Text(
                          state.nextStreet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NightRoadType.title.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NightRoadSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      GlanceCopy.eta(GlanceFormat.clock(state.arrival), state.remainingM),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.body.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  NightRoadRoundButton(icon: Icons.close_rounded, onPressed: onStop),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
