final class SequenceGate {
  static const int resyncAfter = 10;
  static const int window = 0x8000;

  int _rejectStreak = 0;

  int? _last;

  bool accept(int sequence) {
    final last = _last;
    final delta = last == null ? 1 : (sequence - last) & 0xFFFF;
    if ((delta == 0 || delta >= window) && _rejectStreak < resyncAfter - 1) {
      _rejectStreak++;
      return false;
    }
    _last = sequence;
    _rejectStreak = 0;
    return true;
  }

  void reset() {
    _last = null;
    _rejectStreak = 0;
  }
}
