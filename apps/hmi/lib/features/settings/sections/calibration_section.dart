import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../widgets/keypad_entry.dart';

class CalibrationSection extends ConsumerStatefulWidget {
  const CalibrationSection({super.key});

  @override
  ConsumerState<CalibrationSection> createState() => _CalibrationSectionState();
}

class _CalibrationSectionState extends ConsumerState<CalibrationSection> {
  static const double factorScale = 10000;
  static const double knownDistanceKm = 1;
  static const double maxShownKm = 2;
  static const double minShownKm = 0.5;

  static const Map<int, String> fuelLevels = {0: GlanceCopy.fuelEmpty, 25: GlanceCopy.fuelQuarter, 50: GlanceCopy.fuelHalf, 75: GlanceCopy.fuelThreeQuarters, 100: GlanceCopy.fuelFull};

  bool _enteringWheel = false;

  int? _savedFuelPercent;

  void _submitWheel(String value) {
    final factor = knownDistanceKm / double.parse(value);
    unawaited(ref.read(telemetryHubProvider).send(SetWheelCalibrationMessage(factorX10000: (factor * factorScale).round())));
    setState(() => _enteringWheel = false);
  }

  String? _validate(String value) {
    final shown = double.tryParse(value);
    return shown == null || shown < minShownKm || shown > maxShownKm ? GlanceCopy.wheelCalibrationInvalid : null;
  }

  void _saveFuel(int percent) {
    unawaited(ref.read(telemetryHubProvider).send(SaveFuelPointMessage(percent: percent)));
    setState(() => _savedFuelPercent = percent);
  }

  @override
  Widget build(BuildContext context) {
    if (_enteringWheel) {
      return KeypadEntry(allowDecimal: true, body: GlanceCopy.wheelCalibrationBody, onCancel: () => setState(() => _enteringWheel = false), onSubmit: _submitWheel, unit: GlanceCopy.kmUnit, validate: _validate);
    }
    final colors = context.colors;
    final bodyStyle = NightRoadType.body.copyWith(color: colors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NightRoadLabel(GlanceCopy.wheel),
        const SizedBox(height: NightRoadSpacing.sm),
        Text(GlanceCopy.wheelCalibrationBody, maxLines: 2, overflow: TextOverflow.ellipsis, style: bodyStyle),
        const SizedBox(height: NightRoadSpacing.md),
        NightRoadButton(color: colors.textPrimary, label: GlanceCopy.enterDistance, onPressed: () => setState(() => _enteringWheel = true)),
        const SizedBox(height: NightRoadSpacing.xxl),
        const NightRoadLabel(GlanceCopy.fuel),
        const SizedBox(height: NightRoadSpacing.sm),
        Text(GlanceCopy.fuelCalibrationBody, maxLines: 2, overflow: TextOverflow.ellipsis, style: bodyStyle),
        const SizedBox(height: NightRoadSpacing.md),
        Row(
          spacing: NightRoadSpacing.sm,
          children: [
            for (final level in fuelLevels.entries)
              Expanded(
                child: NightRoadChoice(label: level.value, onSelected: () => _saveFuel(level.key), selected: _savedFuelPercent == level.key),
              ),
          ],
        ),
        const SizedBox(height: NightRoadSpacing.sm),
        Text(
          _savedFuelPercent == null ? '' : GlanceCopy.saved,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: NightRoadType.caption.copyWith(color: colors.stateEco),
        ),
      ],
    );
  }
}
