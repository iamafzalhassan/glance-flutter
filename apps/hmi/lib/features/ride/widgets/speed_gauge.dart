import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:night_road/night_road.dart';

import '../../../core/layout/text_measure.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../../../core/providers/vehicle_providers.dart';
import 'drive_badges.dart';
import 'speed_block.dart';
import 'speed_gauge_geometry.dart';

class SpeedGauge extends ConsumerWidget {
  const SpeedGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxKmh = ref.watch(vehicleProfileProvider.select((profile) => profile.value?.maxDisplayKmh)) ?? 0;
    final colors = context.colors;
    final labelStyle = NightRoadType.caption.copyWith(color: colors.textMuted);
    final readoutSize = SpeedBlock.naturalSize(MediaQuery.textScalerOf(context));
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final geometry = SpeedGaugeGeometry.resolve(labelSize: (text) => TextMeasure.of(text, labelStyle), maxKmh: maxKmh, readoutSize: readoutSize, size: constraints.biggest);
          return Stack(
            fit: StackFit.expand,
            children: [
              if (maxKmh > 0)
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _ScalePainter(geometry: geometry, labelStyle: labelStyle, tick: colors.lineSubtle, track: colors.bgRaised),
                  ),
                ),
              if (maxKmh > 0) _GaugeFill(geometry: geometry, maxKmh: maxKmh),
              Positioned.fromRect(
                rect: geometry.readout,
                child: const FittedBox(child: SpeedBlock()),
              ),
              Positioned.fromRect(
                rect: geometry.chin,
                child: const Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: DriveBadges()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugeFill extends ConsumerWidget {
  const _GaugeFill({required this.maxKmh, required this.geometry});

  final double maxKmh;

  final SpeedGaugeGeometry geometry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(telemetryProvider.select((snapshot) => snapshot.speedKmh.liveValue ?? 0));
    final eco = ref.watch(telemetryProvider.select((snapshot) => snapshot.has(TelemetryFlag.eco)));
    final colors = context.colors;
    return TweenAnimationBuilder<Color?>(
      builder: (context, fill, _) => CustomPaint(
        painter: _FillPainter(fill: fill ?? colors.textSecondary, fraction: (speed / maxKmh).clamp(0, 1), geometry: geometry),
      ),
      curve: NightRoadMotion.quickCurve,
      duration: NightRoadMotion.of(context, NightRoadMotion.quick),
      tween: ColorTween(end: eco ? colors.stateEco : colors.textSecondary),
    );
  }
}

class _FillPainter extends CustomPainter {
  final double fraction;

  final Color fill;

  final SpeedGaugeGeometry geometry;

  const _FillPainter({required this.fraction, required this.fill, required this.geometry});

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0) return;
    final stroke = Paint()
      ..color = fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NightRoadSpacing.gaugeStroke
      ..style = PaintingStyle.stroke;
    canvas.drawArc(geometry.arc, SpeedGaugeGeometry.startAngle, SpeedGaugeGeometry.sweepAngle * fraction, false, stroke);
  }

  @override
  bool shouldRepaint(_FillPainter oldDelegate) => oldDelegate.fraction != fraction || oldDelegate.fill != fill || oldDelegate.geometry != geometry;
}

class _ScalePainter extends CustomPainter {
  final Color tick;
  final Color track;

  final SpeedGaugeGeometry geometry;

  final TextStyle labelStyle;

  const _ScalePainter({required this.tick, required this.track, required this.geometry, required this.labelStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = track
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NightRoadSpacing.gaugeStroke
      ..style = PaintingStyle.stroke;
    canvas.drawArc(geometry.arc, SpeedGaugeGeometry.startAngle, SpeedGaugeGeometry.sweepAngle, false, stroke);
    final major = Paint()
      ..color = tick
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NightRoadSpacing.outline;
    final minor = Paint()
      ..color = tick
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NightRoadSpacing.hairline;
    for (final mark in geometry.ticks) {
      canvas.drawLine(mark.inner, mark.outer, mark.major ? major : minor);
    }
    for (final label in geometry.labels) {
      final painter = TextPainter(
        maxLines: 1,
        text: TextSpan(style: labelStyle, text: label.text),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, label.rect.topLeft);
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(_ScalePainter oldDelegate) => oldDelegate.tick != tick || oldDelegate.track != track || oldDelegate.geometry != geometry || oldDelegate.labelStyle != labelStyle;
}
