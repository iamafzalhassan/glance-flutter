import 'package:flutter/painting.dart';

abstract final class TextMeasure {
  static Size of(String text, TextStyle style, {TextScaler textScaler = TextScaler.noScaling}) {
    final painter = TextPainter(
      maxLines: 1,
      text: TextSpan(style: style, text: text),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }
}
