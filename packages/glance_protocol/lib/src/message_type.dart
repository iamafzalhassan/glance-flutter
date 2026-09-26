enum MessageType {
  telemetry(0x01, 20),
  status(0x02, 7),
  event(0x03, 3),
  ack(0x7F, 1),
  setOdometer(0x10, 4),
  resetTrip(0x11, 1),
  setWheelCalibration(0x12, 4),
  saveFuelPoint(0x13, 1),
  requestRawSignals(0x14, 1),
  ping(0x15, 0);

  final int code;
  final int payloadLength;

  const MessageType(this.code, this.payloadLength);

  static MessageType? fromCode(int code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }
}
