abstract interface class TelemetrySource {
  Stream<List<int>> get bytes;

  Future<void> close();

  Future<void> send(List<int> bytes);
}
