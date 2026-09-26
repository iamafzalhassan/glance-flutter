final class BatteryWatch {
  static const int recoverMarginMv = 200;

  static const Duration holdFor = Duration(seconds: 30);

  bool _low = false;

  Duration? _belowSince;

  bool update({required int lowMv, required int millivolts, required Duration now}) {
    if (_low) {
      if (millivolts >= lowMv + recoverMarginMv) _low = false;
      return _low;
    }
    if (millivolts >= lowMv) {
      _belowSince = null;
      return false;
    }
    final since = _belowSince ??= now;
    _low = now - since >= holdFor;
    if (_low) _belowSince = null;
    return _low;
  }
}
