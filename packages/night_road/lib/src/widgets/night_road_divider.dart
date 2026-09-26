import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_spacing.dart';

class NightRoadDivider extends StatelessWidget {
  const NightRoadDivider({super.key, this.dotted = false, this.axis = Axis.vertical});

  final bool dotted;

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.lineSubtle;
    final thickness = dotted ? NightRoadSpacing.outline : NightRoadSpacing.hairline;
    final line = axis == Axis.vertical ? SizedBox(width: thickness) : SizedBox(height: thickness);
    return dotted
        ? CustomPaint(
            painter: _DotPainter(axis: axis, color: color),
            child: line,
          )
        : ColoredBox(color: color, child: line);
  }
}

class _DotPainter extends CustomPainter {
  static const double pitch = NightRoadSpacing.xs;

  final Axis axis;

  final Color color;

  const _DotPainter({required this.axis, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = size.shortestSide / 2;
    final length = axis == Axis.horizontal ? size.width : size.height;
    for (var along = radius; along <= length - radius; along += pitch) {
      canvas.drawCircle(axis == Axis.horizontal ? Offset(along, radius) : Offset(radius, along), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => oldDelegate.axis != axis || oldDelegate.color != color;
}
