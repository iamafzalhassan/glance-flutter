final class ArrivalWatch {
  static const int arrivedWithinM = 30;

  bool _approaching = false;

  bool hasArrived(int remainingM) {
    if (remainingM > arrivedWithinM) _approaching = true;
    return _approaching && remainingM <= arrivedWithinM;
  }
}
