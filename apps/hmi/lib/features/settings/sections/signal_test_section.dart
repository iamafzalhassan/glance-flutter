import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/telemetry_providers.dart';

class SignalTestSection extends ConsumerStatefulWidget {
  const SignalTestSection({super.key});

  @override
  ConsumerState<SignalTestSection> createState() => _SignalTestSectionState();
}

class _SignalTestSectionState extends ConsumerState<SignalTestSection> {
  static const double tileWidth = 196;

  late final TelemetryHub _hub = ref.read(telemetryHubProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_hub.send(const RequestRawSignalsMessage(enabled: true)));
  }

  @override
  void dispose() {
    unawaited(_hub.send(const RequestRawSignalsMessage(enabled: false)));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(telemetryProvider);
    final stats = snapshot.stats;
    final flags = snapshot.flags.liveValue ?? 0;
    final fuelRawMv = snapshot.fuelRawMv.value;
    final bikeMv = snapshot.bikeMv.value;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: NightRoadSpacing.sm,
            spacing: NightRoadSpacing.sm,
            children: [
              _StatTile(alert: !snapshot.linkUp, label: GlanceCopy.bikeLink, value: snapshot.linkUp ? GlanceCopy.linkUp : GlanceCopy.linkDown),
              _StatTile(label: GlanceCopy.framesPerSecond, value: '${stats.framesPerSecond}'),
              _StatTile(label: GlanceCopy.delay, value: GlanceCopy.milliseconds(stats.delayMs)),
              _StatTile(alert: stats.discardedFrames > 0, label: GlanceCopy.discarded, value: '${stats.discardedFrames}'),
              _StatTile(label: GlanceCopy.outOfOrder, value: '${stats.outOfOrderFrames}'),
              _StatTile(label: GlanceCopy.speedSpikes, value: '${stats.spikeFrames}'),
              for (final reason in FrameRejection.values) _StatTile(label: GlanceCopy.rejection(reason), value: '${stats.rejectedFor(reason)}'),
              _StatTile(label: GlanceCopy.fuelSender, value: fuelRawMv == null ? GlanceCopy.noSignal : GlanceCopy.millivolts(fuelRawMv)),
              _StatTile(label: GlanceCopy.bikeVoltage, value: bikeMv == null ? GlanceCopy.noSignal : GlanceCopy.volts(bikeMv)),
            ],
          ),
          const SizedBox(height: NightRoadSpacing.xl),
          const NightRoadLabel(GlanceCopy.inputs),
          const SizedBox(height: NightRoadSpacing.sm),
          Wrap(
            runSpacing: NightRoadSpacing.sm,
            spacing: NightRoadSpacing.sm,
            children: [for (final flag in TelemetryFlag.values) _InputTile(label: GlanceCopy.flag(flag), on: flags & flag.mask != 0)],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({this.alert = false, required this.label, required this.value});

  final bool alert;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: _SignalTestSectionState.tileWidth,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: colors.bgRaised, shape: NightRoadRadius.cardShape),
        child: Padding(
          padding: const EdgeInsets.all(NightRoadSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.caption.copyWith(color: colors.textMuted),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.title.copyWith(color: alert ? colors.stateWarn : colors.textPrimary, fontFeatures: NightRoadType.tabular),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputTile extends StatelessWidget {
  const _InputTile({required this.on, required this.label});

  final bool on;

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: NightRoadSpacing.touch,
      width: _SignalTestSectionState.tileWidth,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: colors.bgRaised, shape: NightRoadRadius.cardShape),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.md),
          child: Row(
            spacing: NightRoadSpacing.sm,
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(color: on ? colors.stateEco : colors.lineSubtle, shape: NightRoadRadius.pillShape),
                child: const SizedBox.square(dimension: NightRoadSpacing.md),
              ),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NightRoadType.caption.copyWith(color: colors.textSecondary),
                ),
              ),
              Text(
                on ? GlanceCopy.on : GlanceCopy.off,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.caption.copyWith(color: on ? colors.textPrimary : colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
