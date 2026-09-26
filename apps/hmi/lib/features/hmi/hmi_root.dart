import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/providers/device_providers.dart';
import '../../core/providers/display_providers.dart';
import '../../core/providers/settings_providers.dart';
import '../../core/providers/telemetry_providers.dart';
import '../../core/providers/vehicle_providers.dart';
import '../../core/widgets/design_canvas.dart';
import '../alerts/alert_layer.dart';
import '../boot/boot_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../parked/parked_screen.dart';
import '../settings/settings_screen.dart';
import '../status/signal_lost_banner.dart';
import '../status/status_bar.dart';
import '../trip_summary/ride_summary.dart';
import '../trip_summary/trip_summary_screen.dart';

class HmiRoot extends ConsumerStatefulWidget {
  const HmiRoot({super.key});

  @override
  ConsumerState<HmiRoot> createState() => _HmiRootState();
}

class _HmiRootState extends ConsumerState<HmiRoot> {
  bool _booted = false;

  void _finishBoot() => setState(() => _booted = true);

  @override
  Widget build(BuildContext context) {
    ref.watch(telemetryHubProvider);
    ref.watch(devicePowerProvider);
    ref.watch(rideSummaryProvider);
    final day = ref.watch(displayThemeProvider) == DisplayTheme.day;
    final reduceMotion = ref.watch(settingsProvider.select((settings) => settings.reduceMotion));
    final ready = _booted && ref.watch(vehicleProfileProvider).hasValue;
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(disableAnimations: media.disableAnimations || reduceMotion),
      child: AnimatedTheme(
        curve: NightRoadMotion.standardCurve,
        data: day ? NightRoadTheme.day : NightRoadTheme.night,
        duration: NightRoadMotion.standard,
        child: Builder(
          builder: (context) => Material(
            color: context.colors.bgBase,
            child: DesignCanvas(
              child: AnimatedSwitcher(
                duration: NightRoadMotion.of(context, NightRoadMotion.standard),
                switchInCurve: NightRoadMotion.standardCurve,
                switchOutCurve: NightRoadMotion.standardCurve,
                child: ready ? const _HmiLayout() : BootScreen(onFinished: _finishBoot),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HmiLayout extends ConsumerWidget {
  const _HmiLayout();

  static const double _asleepScrim = 1;
  static const double _parkedScrim = 0.4;

  Widget _content(DevicePower power, HmiSurface surface, RideSummary? summary) => switch ((power, surface)) {
    (DevicePower.summary, _) when summary != null => TripSummaryScreen(key: const ValueKey(DevicePower.summary), summary: summary),
    (DevicePower.summary || DevicePower.parked || DevicePower.asleep, _) => const ParkedScreen(key: ValueKey(DevicePower.parked)),
    (_, HmiSurface.settings) => const SettingsScreen(key: ValueKey(HmiSurface.settings)),
    _ => const DashboardScreen(key: ValueKey(HmiSurface.dashboard)),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final power = ref.watch(devicePowerProvider);
    final surface = ref.watch(hmiSurfaceProvider);
    final summary = ref.watch(rideSummaryProvider);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(NightRoadSpacing.margin, 0, NightRoadSpacing.margin, NightRoadSpacing.gutter),
          child: Column(
            children: [
              const StatusBar(),
              Expanded(
                child: AnimatedSwitcher(duration: NightRoadMotion.of(context, NightRoadMotion.standard), switchInCurve: NightRoadMotion.standardCurve, switchOutCurve: NightRoadMotion.standardCurve, child: _content(power, surface, summary)),
              ),
            ],
          ),
        ),
        const Positioned(left: NightRoadSpacing.margin, right: NightRoadSpacing.margin, top: NightRoadSpacing.statusBar, child: SignalLostBanner()),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: power != DevicePower.asleep,
            child: AnimatedOpacity(
              curve: NightRoadMotion.gentleCurve,
              duration: NightRoadMotion.of(context, NightRoadMotion.gentle),
              opacity: switch (power) {
                DevicePower.awake || DevicePower.summary => 0,
                DevicePower.parked => _parkedScrim,
                DevicePower.asleep => _asleepScrim,
              },
              child: ColoredBox(color: context.colors.bgBase),
            ),
          ),
        ),
        const Positioned.fill(child: AlertLayer()),
      ],
    );
  }
}
