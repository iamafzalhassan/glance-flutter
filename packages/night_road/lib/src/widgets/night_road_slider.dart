import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_motion.dart';
import '../night_road_spacing.dart';
import '../night_road_type.dart';

class NightRoadSlider extends StatefulWidget {
  const NightRoadSlider({super.key, required this.divisions, required this.max, this.min = 0, required this.value, required this.label, this.labelStyle = NightRoadType.caption, required this.onChanged});

  final int divisions;

  final double max;
  final double min;
  final double value;

  final String Function(double value) label;

  final TextStyle labelStyle;

  final ValueChanged<double> onChanged;

  @override
  State<NightRoadSlider> createState() => _NightRoadSliderState();
}

class _NightRoadSliderState extends State<NightRoadSlider> {
  double? _dragFraction;

  void _drag(double dx, double width) {
    const inset = _SliderPainter.thumbRadius;
    final fraction = ((dx - inset) / max(1, width - inset * 2)).clamp(0.0, 1.0);
    setState(() => _dragFraction = fraction);
    final next = _stop((fraction * widget.divisions).round());
    if (next != widget.value) widget.onChanged(next);
  }

  double _stop(int index) => widget.min + (widget.max - widget.min) * index / widget.divisions;

  void _release() => setState(() => _dragFraction = null);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = widget.labelStyle;
    final labels = [for (var index = 0; index <= widget.divisions; index++) widget.label(_stop(index))];
    final snapped = ((widget.value - widget.min) / (widget.max - widget.min) * widget.divisions).round().clamp(0, widget.divisions) / widget.divisions;
    final height = NightRoadSpacing.sliderThumb + NightRoadSpacing.sm + style.fontSize! * (style.height ?? 1);
    return Semantics(
      slider: true,
      value: widget.label(widget.value),
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragCancel: _release,
          onHorizontalDragEnd: (_) => _release(),
          onHorizontalDragStart: (details) => _drag(details.localPosition.dx, constraints.maxWidth),
          onHorizontalDragUpdate: (details) => _drag(details.localPosition.dx, constraints.maxWidth),
          onTapUp: (details) {
            _drag(details.localPosition.dx, constraints.maxWidth);
            _release();
          },
          child: TweenAnimationBuilder<double>(
            builder: (context, fraction, _) => CustomPaint(
              painter: _SliderPainter(
                fraction: fraction,
                labels: labels,
                labelStyle: style.copyWith(color: colors.textMuted),
                line: colors.lineSubtle,
                selectedStyle: style.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                thumb: colors.textPrimary,
              ),
              size: Size(constraints.maxWidth, height),
            ),
            curve: NightRoadMotion.quickCurve,
            duration: NightRoadMotion.of(context, _dragFraction == null ? NightRoadMotion.quick : Duration.zero),
            tween: Tween(end: _dragFraction ?? snapped),
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  static const double thumbRadius = NightRoadSpacing.sliderThumb / 2;
  static const double tickHalf = NightRoadSpacing.md / 2;

  final double fraction;

  final List<String> labels;

  final Color line;
  final Color thumb;

  final TextStyle labelStyle;
  final TextStyle selectedStyle;

  const _SliderPainter({required this.fraction, required this.labels, required this.line, required this.thumb, required this.labelStyle, required this.selectedStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final span = size.width - thumbRadius * 2;
    final last = labels.length - 1;
    final selected = (fraction * last).round();
    final stroke = Paint()
      ..color = line
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NightRoadSpacing.xs;
    canvas.drawLine(const Offset(thumbRadius, thumbRadius), Offset(thumbRadius + span, thumbRadius), stroke);
    stroke.strokeWidth = NightRoadSpacing.outline;
    final painters = [
      for (var index = 0; index <= last; index++)
        TextPainter(
          maxLines: 1,
          text: TextSpan(style: index == selected ? selectedStyle : labelStyle, text: labels[index]),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final widest = painters.fold(0.0, (widest, painter) => max(widest, painter.width));
    final every = last == 0 ? 1 : max(1, ((widest + NightRoadSpacing.sm) * last / span).ceil());
    for (var index = 0; index <= last; index++) {
      final x = thumbRadius + (last == 0 ? 0 : span * index / last);
      canvas.drawLine(Offset(x, thumbRadius - tickHalf), Offset(x, thumbRadius + tickHalf), stroke);
      if (index % every == 0) painters[index].paint(canvas, Offset(x - painters[index].width / 2, NightRoadSpacing.sliderThumb + NightRoadSpacing.sm));
      painters[index].dispose();
    }
    canvas.drawCircle(Offset(thumbRadius + span * fraction, thumbRadius), thumbRadius, Paint()..color = thumb);
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) =>
      oldDelegate.fraction != fraction || !listEquals(oldDelegate.labels, labels) || oldDelegate.line != line || oldDelegate.thumb != thumb || oldDelegate.labelStyle != labelStyle || oldDelegate.selectedStyle != selectedStyle;
}
