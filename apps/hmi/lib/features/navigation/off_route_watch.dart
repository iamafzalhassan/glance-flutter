final class OffRouteWatch {
  static const double offRouteM = 50;

  static const int confirmFixes = 3;

  static const Duration minInterval = Duration(seconds: 15);

  int _offFixes = 0;

  Duration? _lastReroute;

  bool shouldReroute(double offM, Duration now) {
    _offFixes = offM > offRouteM ? _offFixes + 1 : 0;
    final last = _lastReroute;
    if (_offFixes < confirmFixes || (last != null && now - last < minInterval)) return false;
    _offFixes = 0;
    _lastReroute = now;
    return true;
  }
}
