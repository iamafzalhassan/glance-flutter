import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'map_palette.dart';
import 'rider_arrow.dart';

class SchematicMapView extends StatelessWidget {
  const SchematicMapView({super.key, required this.progress, required this.routeColor, required this.palette});

  final double progress;

  final Color routeColor;

  final MapPalette palette;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _SchematicMapPainter(palette: palette, progress: progress, routeColor: routeColor),
      size: Size.infinite,
    ),
  );
}

class _SchematicMapPainter extends CustomPainter {
  static const double gridStep = 0.16;
  static const double roadWidth = 10;
  static const double routeWidth = 8;

  static const List<Offset> route = [Offset(0.18, 0.92), Offset(0.18, 0.62), Offset(0.52, 0.62), Offset(0.52, 0.34), Offset(0.84, 0.34), Offset(0.84, 0.08)];

  final double progress;

  final Color routeColor;

  final MapPalette palette;

  const _SchematicMapPainter({required this.progress, required this.routeColor, required this.palette});

  void _paintRoads(Canvas canvas, Size size) {
    final road = Paint()
      ..color = palette.road
      ..strokeCap = StrokeCap.round
      ..strokeWidth = roadWidth;
    for (var fraction = gridStep / 2; fraction < 1; fraction += gridStep) {
      canvas.drawLine(Offset(fraction * size.width, 0), Offset(fraction * size.width, size.height), road);
      canvas.drawLine(Offset(0, fraction * size.height), Offset(size.width, fraction * size.height), road);
    }
  }

  Path _routePath(Size size) {
    final path = Path()..moveTo(route.first.dx * size.width, route.first.dy * size.height);
    for (final point in route.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    return path;
  }

  void _paintPosition(Canvas canvas, Tangent tangent) {
    canvas
      ..save()
      ..translate(tangent.position.dx, tangent.position.dy)
      ..rotate(-tangent.angle + pi / 2);
    RiderArrow(fill: routeColor, outline: palette.base).paint(canvas);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.base);
    _paintRoads(canvas, size);
    final metric = _routePath(size).computeMetrics().first;
    final travelled = metric.length * progress.clamp(0, 1);
    canvas.drawPath(
      metric.extractPath(travelled, metric.length),
      Paint()
        ..color = routeColor
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = routeWidth
        ..style = PaintingStyle.stroke,
    );
    final tangent = metric.getTangentForOffset(travelled);
    if (tangent != null) _paintPosition(canvas, tangent);
  }

  @override
  bool shouldRepaint(_SchematicMapPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.routeColor != routeColor || oldDelegate.palette != palette;
}
