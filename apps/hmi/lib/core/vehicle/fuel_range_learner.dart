final class FuelRangeLearner {
  static const double learnAfterKm = 20;
  static const double minDropPercent = 3;
  static const double newWeight = 0.3;
  static const double refuelRisePercent = 5;

  static const int metersPerKm = 1000;
  static const int rangeStepKm = 10;

  double? _anchorFuel;

  int? _anchorOdometerM;

  double learn({required double fuelPercent, required double learned, required int odometerM}) {
    final anchorFuel = _anchorFuel;
    final anchorOdometerM = _anchorOdometerM;
    if (anchorFuel == null || anchorOdometerM == null || fuelPercent > anchorFuel + refuelRisePercent || odometerM < anchorOdometerM) {
      _anchor(fuelPercent, odometerM);
      return learned;
    }
    final km = (odometerM - anchorOdometerM) / metersPerKm;
    final drop = anchorFuel - fuelPercent;
    if (km < learnAfterKm || drop < minDropPercent) return learned;
    _anchor(fuelPercent, odometerM);
    final sample = drop / km;
    return learned <= 0 ? sample : learned + (sample - learned) * newWeight;
  }

  static int? rangeKm(double fuelPercent, double learned) => learned > 0 ? (fuelPercent / learned / rangeStepKm).round() * rangeStepKm : null;

  void _anchor(double fuelPercent, int odometerM) {
    _anchorFuel = fuelPercent;
    _anchorOdometerM = odometerM;
  }
}
