abstract final class Crc16 {
  static const int initial = 0xFFFF;
  static const int polynomial = 0x1021;

  static int compute(List<int> bytes, [int start = 0, int? end]) {
    var crc = initial;
    final stop = end ?? bytes.length;
    for (var index = start; index < stop; index++) {
      crc ^= (bytes[index] & 0xFF) << 8;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ polynomial) & 0xFFFF : (crc << 1) & 0xFFFF;
      }
    }
    return crc;
  }
}
