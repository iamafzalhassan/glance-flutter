import 'geo_point.dart';

abstract final class PolylineCodec {
  static const double precision = 1e5;

  static const int asciiOffset = 63;
  static const int chunkBits = 5;
  static const int chunkMask = 0x1F;
  static const int continueBit = 0x20;

  static List<GeoPoint> decode(String encoded) {
    final points = <GeoPoint>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;
    int next() {
      var result = 0;
      var shift = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - asciiOffset;
        result |= (byte & chunkMask) << shift;
        shift += chunkBits;
      } while (byte >= continueBit);
      return result.isOdd ? ~(result >> 1) : result >> 1;
    }

    while (index < encoded.length) {
      latitude += next();
      longitude += next();
      points.add(GeoPoint(latitude / precision, longitude / precision));
    }
    return points;
  }
}
