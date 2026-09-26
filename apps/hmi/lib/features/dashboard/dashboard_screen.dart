import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_maps/glance_maps.dart';
import 'package:night_road/night_road.dart';

import '../../core/providers/display_providers.dart';
import '../../core/providers/map_providers.dart';
import '../navigation/navigation_providers.dart';
import '../notices/notice.dart';
import '../notices/notice_card.dart';
import '../ride/widgets/fuel_gauge.dart';
import '../ride/widgets/odometer_line.dart';
import '../ride/widgets/speed_gauge.dart';
import 'widgets/parked_actions.dart';
import 'widgets/places_panel.dart';
import 'widgets/turn_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const double _instrumentWidth = 392;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(navigationProvider);
    final session = ref.watch(navigationSessionProvider);
    final places = ref.watch(hmiSurfaceProvider) == HmiSurface.places;
    final location = ref.watch(riderLocationProvider).value;
    final notice = ref.watch(noticeProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          width: _instrumentWidth,
          child: NightRoadModule(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(child: RepaintBoundary(child: SpeedGauge())),
                ),
                SizedBox(height: NightRoadSpacing.xl),
                RepaintBoundary(child: FuelGauge()),
                SizedBox(height: NightRoadSpacing.lg),
                OdometerLine(),
              ],
            ),
          ),
        ),
        const SizedBox(width: NightRoadSpacing.gutter),
        Expanded(
          child: ClipRSuperellipse(
            borderRadius: NightRoadRadius.panelAll,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GlanceMapView(
                    centre: defaultMapCentre,
                    google: ref.watch(useGoogleMapsProvider),
                    heading: location?.bearing ?? 0,
                    night: ref.watch(displayThemeProvider) == DisplayTheme.night,
                    path: session?.route.path ?? const [],
                    progress: navigation?.progress ?? 0,
                    rider: location?.position,
                    routeColor: context.colors.accentNav,
                  ),
                ),
                Positioned(
                  left: NightRoadSpacing.moduleInset,
                  top: NightRoadSpacing.moduleInset,
                  child: _OverlaySwitcher(
                    child: places
                        ? null
                        : navigation != null
                        ? TurnCard(key: const ValueKey(TurnCard), onStop: ref.read(navigationSessionProvider.notifier).stop, state: navigation)
                        : notice == null
                        ? null
                        : NoticeCard(key: ValueKey(notice), notice: notice),
                  ),
                ),
                const Positioned(right: NightRoadSpacing.moduleInset, top: NightRoadSpacing.moduleInset, child: ParkedActions()),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(NightRoadSpacing.moduleInset),
                    child: _OverlaySwitcher(child: places ? const PlacesPanel(key: ValueKey(PlacesPanel)) : null),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlaySwitcher extends StatelessWidget {
  const _OverlaySwitcher({required this.child});

  static const Offset _enterFrom = Offset(0, 0.04);

  final Widget? child;

  Widget _transition(Widget child, Animation<double> animation) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(begin: _enterFrom, end: Offset.zero).animate(animation),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: NightRoadMotion.of(context, NightRoadMotion.standard),
    layoutBuilder: (current, previous) => Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
    switchInCurve: NightRoadMotion.standardCurve,
    switchOutCurve: NightRoadMotion.standardCurve,
    transitionBuilder: _transition,
    child: child ?? const SizedBox.shrink(),
  );
}
