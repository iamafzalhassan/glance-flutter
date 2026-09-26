import 'package:flutter/widgets.dart';
import 'package:night_road/night_road.dart';

enum TellTale { left, highBeam, engine, sideStand, right }

class TellTaleIcon extends StatelessWidget {
  const TellTaleIcon({super.key, this.size = NightRoadSpacing.telltale, required this.color, required this.kind});

  final double size;

  final Color color;

  final TellTale kind;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _TellTalePainter(color: color, kind: kind),
    size: Size.square(size),
  );
}

class _TellTalePainter extends CustomPainter {
  static const double grid = 24;
  static const double standPivotRadius = 2.5;
  static const double stroke = 2;

  static const List<Offset> arrow = [Offset(2, 12), Offset(11, 4), Offset(11, 9), Offset(22, 9), Offset(22, 15), Offset(11, 15), Offset(11, 20)];
  static const List<Offset> beams = [Offset(2, 6), Offset(10, 6), Offset(2, 9), Offset(10, 9), Offset(2, 12), Offset(10, 12), Offset(2, 15), Offset(10, 15), Offset(2, 18), Offset(10, 18)];
  static const List<Offset> engine = [
    Offset(3, 10),
    Offset(5, 10),
    Offset(5, 8),
    Offset(8, 8),
    Offset(8, 6),
    Offset(15, 6),
    Offset(15, 8),
    Offset(18, 8),
    Offset(18, 11),
    Offset(20, 11),
    Offset(20, 9),
    Offset(22, 9),
    Offset(22, 17),
    Offset(20, 17),
    Offset(20, 15),
    Offset(18, 15),
    Offset(18, 18),
    Offset(9, 18),
    Offset(7, 16),
    Offset(5, 16),
    Offset(5, 14),
    Offset(3, 14),
  ];
  static const List<Offset> lamp = [Offset(14, 5), Offset(23, 5), Offset(23, 19), Offset(14, 19)];
  static const List<Offset> stand = [Offset(8, 6), Offset(16, 18), Offset(13, 18), Offset(21, 18)];

  static const Offset standPivot = Offset(8, 6);

  final Color color;

  final TellTale kind;

  const _TellTalePainter({required this.color, required this.kind});

  void _paintHighBeam(Canvas canvas, double scale, Paint fill, Paint line) {
    final lampPath = Path()
      ..moveTo(lamp[0].dx * scale, lamp[0].dy * scale)
      ..cubicTo(lamp[1].dx * scale, lamp[1].dy * scale, lamp[2].dx * scale, lamp[2].dy * scale, lamp[3].dx * scale, lamp[3].dy * scale)
      ..close();
    canvas.drawPath(lampPath, fill);
    for (var index = 0; index < beams.length; index += 2) {
      canvas.drawLine(beams[index] * scale, beams[index + 1] * scale, line);
    }
  }

  Path _polygon(List<Offset> points, double scale, {bool mirror = false}) => Path()..addPolygon([for (final point in points) Offset((mirror ? grid - point.dx : point.dx) * scale, point.dy * scale)], true);

  void _paintSideStand(Canvas canvas, double scale, Paint fill, Paint line) {
    canvas.drawLine(stand[0] * scale, stand[1] * scale, line);
    canvas.drawLine(stand[2] * scale, stand[3] * scale, line);
    canvas.drawCircle(standPivot * scale, standPivotRadius * scale, fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / grid;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = stroke * scale
      ..style = PaintingStyle.stroke;
    switch (kind) {
      case TellTale.left:
        canvas.drawPath(_polygon(arrow, scale), fill);
      case TellTale.right:
        canvas.drawPath(_polygon(arrow, scale, mirror: true), fill);
      case TellTale.highBeam:
        _paintHighBeam(canvas, scale, fill, line);
      case TellTale.engine:
        canvas.drawPath(_polygon(engine, scale), line);
      case TellTale.sideStand:
        _paintSideStand(canvas, scale, fill, line);
    }
  }

  @override
  bool shouldRepaint(_TellTalePainter oldDelegate) => oldDelegate.color != color || oldDelegate.kind != kind;
}
