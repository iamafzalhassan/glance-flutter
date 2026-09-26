import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../../../core/providers/vehicle_providers.dart';

class FuelGauge extends ConsumerStatefulWidget {
  const FuelGauge({super.key});

  @override
  ConsumerState<FuelGauge> createState() => _FuelGaugeState();
}

class _FuelGaugeState extends ConsumerState<FuelGauge> with SingleTickerProviderStateMixin {
  static const double pulseOpacity = 0.3;
  static const double segmentHeight = 28;

  static const int segmentCount = 8;

  late final Animation<double> _opacity = TweenSequence<double>([TweenSequenceItem(tween: Tween(begin: 1, end: pulseOpacity), weight: 1), TweenSequenceItem(tween: Tween(begin: pulseOpacity, end: 1), weight: 1)])
      .animate(CurvedAnimation(curve: NightRoadMotion.gentleCurve, parent: _pulse));

  late final AnimationController _pulse = AnimationController(duration: NightRoadMotion.gentle, vsync: this);

  void _onLowFuelChanged(bool? previous, bool next) {
    if (next && previous == false && !MediaQuery.disableAnimationsOf(context)) _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(telemetryProvider.select((snapshot) => snapshot.has(TelemetryFlag.lowFuel)), _onLowFuelChanged);
    final fuel = ref.watch(telemetryProvider.select((snapshot) => snapshot.fuelPercent));
    final low = ref.watch(telemetryProvider.select((snapshot) => snapshot.has(TelemetryFlag.lowFuel)));
    final colors = context.colors;
    final percent = fuel.value;
    final stale = fuel.freshness != Freshness.live;
    final accent = stale ? colors.textMuted : (low ? colors.stateWarn : colors.stateEco);
    final range = ref.watch(fuelRangeKmProvider);
    final note = stale ? (percent == null ? null : GlanceCopy.lastKnown) : (range == null ? null : GlanceCopy.fuelRange(range));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const NightRoadLabel(GlanceCopy.fuel),
        const SizedBox(height: NightRoadSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            percent == null
                ? Text(
                    GlanceCopy.noSignal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NightRoadType.title.copyWith(color: colors.textMuted),
                  )
                : Text(GlanceCopy.percent(percent.round()), maxLines: 1, style: NightRoadType.numLarge.copyWith(color: stale ? colors.textMuted : colors.textPrimary)),
            const SizedBox(width: NightRoadSpacing.sm),
            if (note != null)
              Flexible(
                child: Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NightRoadType.caption.copyWith(color: colors.textMuted),
                ),
              ),
          ],
        ),
        const SizedBox(height: NightRoadSpacing.lg),
        FadeTransition(
          opacity: _opacity,
          child: TweenAnimationBuilder<double>(
            builder: (context, value, _) => SizedBox(
              height: segmentHeight,
              width: double.infinity,
              child: CustomPaint(
                painter: _SegmentPainter(count: segmentCount, empty: colors.bgRaised, fill: accent, fraction: value / 100),
              ),
            ),
            curve: NightRoadMotion.gentleCurve,
            duration: NightRoadMotion.of(context, NightRoadMotion.gentle),
            tween: Tween(end: percent ?? 0),
          ),
        ),
      ],
    );
  }
}

class _SegmentPainter extends CustomPainter {
  final double fraction;

  final int count;

  final Color empty;
  final Color fill;

  const _SegmentPainter({required this.fraction, required this.count, required this.empty, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    const gap = NightRoadSpacing.xs;
    const radius = Radius.circular(NightRoadSpacing.xs);
    final width = (size.width - gap * (count - 1)) / count;
    final emptyPaint = Paint()..color = empty;
    final fillPaint = Paint()..color = fill;
    final filled = fraction.clamp(0, 1) * count;
    for (var index = 0; index < count; index++) {
      final left = index * (width + gap);
      canvas.drawRSuperellipse(RSuperellipse.fromRectAndRadius(Rect.fromLTWH(left, 0, width, size.height), radius), emptyPaint);
      final portion = (filled - index).clamp(0, 1);
      if (portion > 0) canvas.drawRSuperellipse(RSuperellipse.fromRectAndRadius(Rect.fromLTWH(left, 0, width * portion, size.height), radius), fillPaint);
    }
  }

  @override
  bool shouldRepaint(_SegmentPainter oldDelegate) => oldDelegate.fraction != fraction || oldDelegate.count != count || oldDelegate.empty != empty || oldDelegate.fill != fill;
}
