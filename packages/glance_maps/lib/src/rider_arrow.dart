import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart' show BitmapDescriptor;

final class RiderArrow {
  static const double extent = halfLength + outlineWidth;
  static const double halfLength = 14;
  static const double notch = 0.45;
  static const double outlineWidth = 3;
  static const double wing = 0.8;

  final Color fill;
  final Color outline;

  const RiderArrow({required this.fill, required this.outline});

  Future<BitmapDescriptor> toBitmap(double pixelRatio) async {
    final recorder = PictureRecorder();
    paint(
      Canvas(recorder)
        ..scale(pixelRatio)
        ..translate(extent, extent),
    );
    final picture = recorder.endRecording();
    final side = (extent * 2 * pixelRatio).ceil();
    final image = await picture.toImage(side, side);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), imagePixelRatio: pixelRatio);
  }

  void paint(Canvas canvas) {
    final arrow = Path()
      ..moveTo(0, -halfLength)
      ..lineTo(halfLength * wing, halfLength)
      ..lineTo(0, halfLength * notch)
      ..lineTo(-halfLength * wing, halfLength)
      ..close();
    canvas
      ..drawPath(
        arrow,
        Paint()
          ..color = outline
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = outlineWidth * 2
          ..style = PaintingStyle.stroke,
      )
      ..drawPath(arrow, Paint()..color = fill);
  }

  @override
  bool operator ==(Object other) => other is RiderArrow && other.fill == fill && other.outline == outline;

  @override
  int get hashCode => Object.hash(fill, outline);
}
