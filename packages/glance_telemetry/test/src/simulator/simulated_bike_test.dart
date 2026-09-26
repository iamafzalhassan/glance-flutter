import 'package:glance_protocol/glance_protocol.dart';
import 'package:glance_telemetry/glance_telemetry.dart';
import 'package:test/test.dart';

void main() {
  late SimulatedBike bike;

  setUp(() => bike = SimulatedBike(lowFuelPercent: 15));

  test('accelerates toward the target without overshooting', () {
    bike.targetSpeedKmh = 30;
    bike.advance(const Duration(seconds: 1));
    expect(bike.speedKmh, SimulatedBike.accelerationKmhPerSecond);
    bike.advance(const Duration(seconds: 10));
    expect(bike.speedKmh, 30);
  });

  test('adds distance to odometer and both trips', () {
    bike.speedKmh = 36;
    bike.targetSpeedKmh = 36;
    final odometer = bike.odometerM;
    bike.advance(const Duration(seconds: 10));
    expect(bike.odometerM - odometer, closeTo(100, 0.001));
    expect(bike.tripAM, closeTo(36500, 0.001));
  });

  test('blinks the indicator from the lamp, not a timer in the HMI', () {
    bike.leftSwitch = true;
    expect(bike.toMessage().has(TelemetryFlag.left), isTrue);
    bike.advance(SimulatedBike.blinkHalfPeriod);
    expect(bike.toMessage().has(TelemetryFlag.left), isFalse);
    bike.advance(SimulatedBike.blinkHalfPeriod);
    expect(bike.toMessage().has(TelemetryFlag.left), isTrue);
  });

  test('stops the engine after idling at a standstill once the bike has been ridden', () {
    bike.speedKmh = 30;
    bike.targetSpeedKmh = 30;
    bike.advance(const Duration(milliseconds: 50));
    bike.targetSpeedKmh = 0;
    bike.advance(const Duration(seconds: 2));
    expect(bike.speedKmh, 0);
    bike.advance(SimulatedBike.autoStopAfter - const Duration(milliseconds: 50));
    expect(bike.toMessage().has(TelemetryFlag.engineAutoStopped), isFalse);
    bike.advance(const Duration(milliseconds: 50));
    final message = bike.toMessage();
    expect(message.has(TelemetryFlag.stopStartEnabled), isTrue);
    expect(message.has(TelemetryFlag.engineAutoStopped), isTrue);
  });

  test('restarts the engine as soon as the throttle opens', () {
    bike.speedKmh = 30;
    bike.advance(const Duration(seconds: 2));
    bike.advance(SimulatedBike.autoStopAfter);
    expect(bike.stopStart, StopStartMode.autoStopped);
    bike.targetSpeedKmh = 20;
    bike.advance(const Duration(seconds: 1));
    expect(bike.stopStart, StopStartMode.enabled);
    expect(bike.speedKmh, SimulatedBike.accelerationKmhPerSecond);
  });

  test('never stops the engine before the bike has been ridden', () {
    bike.advance(SimulatedBike.autoStopAfter * 2);
    expect(bike.stopStart, StopStartMode.enabled);
  });

  test('never stops the engine with the Stop & Start switch off', () {
    bike.stopStartSwitch = false;
    bike.speedKmh = 30;
    bike.advance(const Duration(seconds: 2));
    bike.advance(SimulatedBike.autoStopAfter);
    final message = bike.toMessage();
    expect(message.has(TelemetryFlag.stopStartEnabled), isFalse);
    expect(message.has(TelemetryFlag.engineAutoStopped), isFalse);
  });

  test('lights Eco while cruising gently and not above the Eco speed', () {
    bike.speedKmh = 40;
    bike.targetSpeedKmh = 40;
    expect(bike.toMessage().has(TelemetryFlag.eco), isTrue);
    bike.speedKmh = 70;
    bike.targetSpeedKmh = 70;
    expect(bike.toMessage().has(TelemetryFlag.eco), isFalse);
  });

  test('turns Eco off under hard acceleration and at a standstill', () {
    bike.speedKmh = 20;
    bike.targetSpeedKmh = 50;
    expect(bike.toMessage().has(TelemetryFlag.eco), isFalse);
    bike.speedKmh = 0;
    bike.targetSpeedKmh = 0;
    expect(bike.toMessage().has(TelemetryFlag.eco), isFalse);
  });

  test('raises low fuel at the configured threshold', () {
    bike.fuelPercent = 15;
    expect(bike.toMessage().has(TelemetryFlag.lowFuel), isTrue);
    bike.fuelPercent = 16;
    expect(bike.toMessage().has(TelemetryFlag.lowFuel), isFalse);
  });

  test('resets only the requested trip', () {
    bike.resetTrip(ResetTripMessage.tripA);
    expect(bike.tripAM, 0);
    expect(bike.tripBM, 1200);
  });
}
