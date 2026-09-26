import 'dart:math';
import 'dart:ui';

import 'package:night_road/night_road.dart';

final class GaugeLabel {
  final String text;

  final Rect rect;

  const GaugeLabel({required this.text, required this.rect});
}

final class GaugeTick {
  final bool major;

  final Offset inner;
  final Offset outer;

  const GaugeTick({required this.major, required this.inner, required this.outer});
}

final class SpeedGaugeGeometry {
  static const double clearance = NightRoadSpacing.sm;
  static const double labelGap = NightRoadSpacing.sm;
  static const double majorStepKmh = 20;
  static const double minorStepKmh = 10;
  static const double startAngle = 5 * pi / 6;
  static const double sweepAngle = 4 * pi / 3;
  static const double tickGap = NightRoadSpacing.sm;

  static const int _centreSteps = 16;
  static const int _searchSteps = 24;

  final double clearRadius;
  final double radius;

  final List<GaugeLabel> labels;

  final List<GaugeTick> ticks;

  final Offset centre;

  final Rect chin;
  final Rect readout;

  const SpeedGaugeGeometry._({required this.clearRadius, required this.radius, required this.labels, required this.ticks, required this.centre, required this.chin, required this.readout});

  factory SpeedGaugeGeometry.resolve({required Size Function(String text) labelSize, required double maxKmh, required Size readoutSize, required Size size}) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - NightRoadSpacing.gaugeStroke / 2;
    final tickOuter = radius - NightRoadSpacing.gaugeStroke / 2 - tickGap;
    final labelRadius = tickOuter - NightRoadSpacing.gaugeTickMajor - labelGap;
    final labels = <GaugeLabel>[];
    final ticks = <GaugeTick>[];
    for (var kmh = 0.0; maxKmh > 0 && kmh <= maxKmh; kmh += minorStepKmh) {
      final major = kmh % majorStepKmh == 0;
      final angle = startAngle + sweepAngle * kmh / maxKmh;
      final direction = Offset(cos(angle), sin(angle));
      final length = major ? NightRoadSpacing.gaugeTickMajor : NightRoadSpacing.gaugeTickMinor;
      ticks.add(GaugeTick(inner: centre + direction * (tickOuter - length), major: major, outer: centre + direction * tickOuter));
      if (!major) continue;
      final text = kmh.round().toString();
      final label = labelSize(text);
      final anchor = centre + direction * labelRadius;
      labels.add(GaugeLabel(rect: anchor - Offset(label.width / 2 * (1 + direction.dx), label.height / 2 * (1 + direction.dy)) & label, text: text));
    }
    final arcBottom = centre.dy + radius * sin(startAngle) + NightRoadSpacing.gaugeStroke / 2;
    final chinTop = min(size.height, labels.fold(arcBottom, (bottom, label) => max(bottom, label.rect.bottom)) + clearance);
    final chin = Rect.fromLTRB(0, chinTop, size.width, size.height);
    final clearRadius = labelRadius + labelGap - clearance;
    final obstacles = [for (final label in labels) label.rect.inflate(clearance)];
    return SpeedGaugeGeometry._(
      clearRadius: clearRadius,
      radius: radius,
      labels: labels,
      ticks: ticks,
      centre: centre,
      chin: chin,
      readout: _clearReadout(centre: centre, chin: chin, clearRadius: clearRadius, obstacles: obstacles, readoutSize: readoutSize),
    );
  }

  Rect get arc => Rect.fromCircle(center: centre, radius: radius);

  static Rect _clearReadout({required Offset centre, required Rect chin, required double clearRadius, required List<Rect> obstacles, required Size readoutSize}) {
    var best = Rect.fromCenter(center: centre, height: 0, width: 0);
    if (readoutSize.isEmpty || clearRadius <= 0) return best;
    final aspect = readoutSize.width / readoutSize.height;
    final step = clearRadius / 2 / _centreSteps;
    for (var index = 0; index <= _centreSteps * 2; index++) {
      final middle = centre.translate(0, (index + 1) ~/ 2 * step * (index.isOdd ? -1 : 1));
      Rect around(double halfHeight) => Rect.fromCenter(center: middle, height: halfHeight * 2, width: halfHeight * 2 * aspect);
      bool fits(double halfHeight) => _fits(around(halfHeight), centre: centre, chin: chin, clearRadius: clearRadius, obstacles: obstacles);
      var low = 0.0;
      var high = min(readoutSize.height / 2, clearRadius);
      if (fits(high)) {
        low = high;
      } else {
        for (var search = 0; search < _searchSteps; search++) {
          final half = (low + high) / 2;
          if (fits(half)) {
            low = half;
          } else {
            high = half;
          }
        }
      }
      if (low > best.height / 2) best = around(low);
    }
    return best;
  }

  static bool _fits(Rect rect, {required Offset centre, required Rect chin, required double clearRadius, required List<Rect> obstacles}) =>
      rect.bottom <= chin.top && [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight].every((corner) => (corner - centre).distance <= clearRadius) && !obstacles.any(rect.overlaps);
}
