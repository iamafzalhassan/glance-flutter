abstract final class GlanceFormat {
  static String clock(DateTime time) => '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';

  static String odometerKm(int meters) => grouped(meters ~/ 1000);

  static String grouped(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  static String tripKm(int meters) => (meters / 1000).toStringAsFixed(1);

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
