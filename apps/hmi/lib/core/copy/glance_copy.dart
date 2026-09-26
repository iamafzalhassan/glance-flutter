import 'package:glance_protocol/glance_protocol.dart';

import '../format/glance_format.dart';
import '../settings/glance_settings.dart';

abstract final class GlanceCopy {
  static const String about = 'About';
  static const String appName = 'Glance';
  static const String appVersion = 'Glance version';
  static const String autoStop = 'Auto stop';
  static const String average = 'Average';
  static const String batteryLow = 'Bike battery low';
  static const String batteryLowBody = 'Charge or check the battery.';
  static const String bikeLink = 'Bike link';
  static const String bikeVoltage = 'Bike voltage';
  static const String brightnessFloor = 'Brightness floor';
  static const String calibration = 'Calibration';
  static const String cancel = 'Cancel';
  static const String delay = 'Delay';
  static const String discarded = 'Discarded frames';
  static const String dismiss = 'Dismiss';
  static const String display = 'Display';
  static const String eco = 'ECO';
  static const String engineWarning = 'Engine warning';
  static const String engineWarningBody = 'Stop safely and check the engine.';
  static const String enterDistance = 'Enter distance';
  static const String exitKiosk = 'Exit kiosk mode';
  static const String exitKioskBody = 'Glance gives back device owner and shows the status bar again.';
  static const String firmware = 'BIM firmware';
  static const String framesPerSecond = 'Frames per second';
  static const String fuel = 'Fuel';
  static const String fuelCalibrationBody = 'Fill up in steps and save each level.';
  static const String fuelEmpty = 'Empty';
  static const String fuelFull = 'Full';
  static const String fuelHalf = '½';
  static const String fuelQuarter = '¼';
  static const String fuelSender = 'Fuel sender';
  static const String fuelThreeQuarters = '¾';
  static const String ignitionOff = 'Ignition off';
  static const String inputs = 'Inputs';
  static const String kmh = 'km/h';
  static const String kmUnit = 'km';
  static const String lastKnown = 'Last known';
  static const String linkDown = 'No signal';
  static const String linkUp = 'Connected';
  static const String lowFuel = 'Low fuel';
  static const String lowFuelBody = 'Refuel soon.';
  static const String nextService = 'Next service';
  static const String noBikeSignalBody = 'No bike signal. Check the cable under the seat.';
  static const String noPlaces = 'No place matches.';
  static const String noSignal = 'No signal';
  static const String odometer = 'Odo';
  static const String odometerAndTrips = 'Odometer and trips';
  static const String odometerEntryBody = 'Enter the reading from the original meter.';
  static const String off = 'Off';
  static const String on = 'On';
  static const String outOfOrder = 'Out of order';
  static const String reduceMotion = 'Reduce motion';
  static const String resetTripA = 'Reset Trip A';
  static const String resetTripB = 'Reset Trip B';
  static const String routeFailed = 'No route found. Try another place.';
  static const String rideTime = 'Ride time';
  static const String save = 'Save';
  static const String saved = 'Saved';
  static const String search = 'Search';
  static const String searchFailed = 'Search did not work. Check the connection.';
  static const String searchHint = 'Type a place or an address.';
  static const String serviceDue = 'Service due';
  static const String serviceEntryBody = 'Enter the odometer reading for the next service. Enter 0 to turn the reminder off.';
  static const String setNextService = 'Set next service';
  static const String setOdometer = 'Set odometer';
  static const String settings = 'Settings';
  static const String signalTest = 'Signal test';
  static const String speedAlert = 'Speed alert';
  static const String speedSpikes = 'Speed spikes';
  static const String stopStart = 'Stop & Start';
  static const String studioBattery = 'Battery';
  static const String studioBimReboot = 'Reboot BIM';
  static const String studioControls = 'Controls';
  static const String studioCrcErrors = 'Corrupt CRC';
  static const String studioDelay = 'Delay';
  static const String studioDropout = 'Signal dropout';
  static const String studioFaults = 'Faults';
  static const String studioFiWarning = 'FI warning';
  static const String studioFuel = 'Fuel';
  static const String studioFuelSlosh = 'Fuel slosh';
  static const String studioHighBeam = 'High beam';
  static const String studioIgnition = 'Ignition';
  static const String studioJitter = 'Jitter';
  static const String studioLeft = 'Left';
  static const String studioNavigation = 'Navigation route';
  static const String studioRight = 'Right';
  static const String studioSideStand = 'Side stand';
  static const String studioSpeed = 'Speed';
  static const String studioSpikes = 'Speed spikes';
  static const String studioStopStart = 'Stop & Start switch';
  static const String studioUnplug = 'Unplug USB for 3 s';
  static const String theme = 'Theme';
  static const String themeAuto = 'Auto';
  static const String themeDay = 'Day';
  static const String themeNight = 'Night';
  static const String topSpeed = 'Top speed';
  static const String tripA = 'Trip A';
  static const String tripB = 'Trip B';
  static const String tripDistance = 'Distance';
  static const String tripSummary = 'Trip summary';
  static const String vehicle = 'Vehicle';
  static const String wheel = 'Wheel';
  static const String wheelCalibrationBody = 'Ride exactly 1.000 km, then enter the distance Glance showed.';
  static const String wheelCalibrationInvalid = 'Enter a distance between 0.500 and 2.000 km.';

  static const List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const List<String> weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String date(DateTime time) => '${weekdayNames[time.weekday - 1]} ${time.day} ${monthNames[time.month - 1]}';

  static String eta(String clock, int remainingMeters) => '$clock · ${distance(remainingMeters)}';

  static String distance(int meters) => meters < 1000 ? '${(meters / 50).round() * 50} m' : '${(meters / 1000).toStringAsFixed(1)} $kmUnit';

  static String firmwareVersion(int version) => '${(version >> 16) & 0xFF}.${(version >> 8) & 0xFF}.${version & 0xFF}';

  static String flag(TelemetryFlag flag) => switch (flag) {
    TelemetryFlag.ignition => 'Ignition',
    TelemetryFlag.eco => 'Eco',
    TelemetryFlag.stopStartEnabled => 'Stop & Start',
    TelemetryFlag.engineAutoStopped => 'Auto stop',
    TelemetryFlag.left => 'Left indicator',
    TelemetryFlag.right => 'Right indicator',
    TelemetryFlag.highBeam => 'High beam',
    TelemetryFlag.fiWarning => 'FI lamp',
    TelemetryFlag.sideStand => 'Side stand',
    TelemetryFlag.lowFuel => 'Low fuel',
    TelemetryFlag.speedSignalOk => 'Speed signal',
    TelemetryFlag.fuelSignalOk => 'Fuel signal',
  };

  static String fuelRange(int km) => 'About $km $kmUnit';

  static String milliseconds(int value) => '$value ms';

  static String millivolts(int value) => '$value mV';

  static String percent(int value) => '$value%';

  static String rejection(FrameRejection reason) => switch (reason) {
    FrameRejection.badCrc => 'Bad CRC',
    FrameRejection.badLength => 'Bad length',
    FrameRejection.unknownType => 'Unknown type',
    FrameRejection.unsupportedVersion => 'Wrong version',
  };

  static String rideDuration(Duration duration) => duration.inHours > 0 ? '${duration.inHours} h ${(duration.inMinutes % 60).toString().padLeft(2, '0')} min' : '${duration.inMinutes} min';

  static String serviceAt(int km) => 'At ${GlanceFormat.grouped(km)} $kmUnit';

  static String serviceIn(int km) => km > 0 ? 'In ${GlanceFormat.grouped(km)} $kmUnit' : 'Overdue by ${GlanceFormat.grouped(-km)} $kmUnit';

  static String themePreference(ThemePreference preference) => switch (preference) {
    ThemePreference.auto => themeAuto,
    ThemePreference.night => themeNight,
    ThemePreference.day => themeDay,
  };

  static String volts(int millivolts) => '${(millivolts / 1000).toStringAsFixed(1)} V';
}
