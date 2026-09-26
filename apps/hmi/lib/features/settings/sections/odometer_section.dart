import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_protocol/glance_protocol.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/format/glance_format.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../widgets/keypad_entry.dart';
import '../widgets/setting_row.dart';

enum _Entry { odometer, service }

class OdometerSection extends ConsumerStatefulWidget {
  const OdometerSection({super.key});

  @override
  ConsumerState<OdometerSection> createState() => _OdometerSectionState();
}

class _OdometerSectionState extends ConsumerState<OdometerSection> {
  static const int metersPerKm = 1000;

  _Entry? _entry;

  String get _entryBody => _entry == _Entry.service ? GlanceCopy.serviceEntryBody : GlanceCopy.odometerEntryBody;

  void _submit(String value) {
    final km = int.parse(value);
    if (_entry == _Entry.service) {
      final settings = ref.read(settingsProvider);
      ref.read(settingsProvider.notifier).update(settings.copyWith(serviceDueKm: km));
    } else {
      _send(SetOdometerMessage(odometerM: km * metersPerKm));
    }
    setState(() => _entry = null);
  }

  void _send(ProtocolMessage message) => unawaited(ref.read(telemetryHubProvider).send(message));

  String? _validate(String value) => int.tryParse(value) == null ? _entryBody : null;

  String _format(int? meters, String Function(int meters) format) => meters == null ? GlanceCopy.noSignal : '${format(meters)} ${GlanceCopy.kmUnit}';

  @override
  Widget build(BuildContext context) {
    if (_entry != null) {
      return KeypadEntry(body: _entryBody, onCancel: () => setState(() => _entry = null), onSubmit: _submit, unit: GlanceCopy.kmUnit, validate: _validate);
    }
    final colors = context.colors;
    final odometer = ref.watch(telemetryProvider.select((snapshot) => snapshot.odometerM.value));
    final tripA = ref.watch(telemetryProvider.select((snapshot) => snapshot.tripAM.value));
    final tripB = ref.watch(telemetryProvider.select((snapshot) => snapshot.tripBM.value));
    final serviceDueKm = ref.watch(settingsProvider.select((settings) => settings.serviceDueKm));
    final valueStyle = NightRoadType.body.copyWith(color: colors.textPrimary, fontFeatures: NightRoadType.tabular);
    Widget row(String label, String value) => SettingRow(
      label: label,
      trailing: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: valueStyle),
    );
    Widget button(String label, VoidCallback onPressed, {bool primary = false}) => Expanded(
      child: NightRoadButton(color: primary ? colors.textPrimary : colors.bgRaised, foreground: primary ? null : colors.textPrimary, label: label, onPressed: onPressed),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(GlanceCopy.odometer, _format(odometer, GlanceFormat.odometerKm)),
        row(GlanceCopy.tripA, _format(tripA, GlanceFormat.tripKm)),
        row(GlanceCopy.tripB, _format(tripB, GlanceFormat.tripKm)),
        row(GlanceCopy.nextService, serviceDueKm > 0 ? GlanceCopy.serviceAt(serviceDueKm) : GlanceCopy.off),
        const Spacer(),
        Row(
          spacing: NightRoadSpacing.sm,
          children: [
            button(GlanceCopy.resetTripA, () => _send(const ResetTripMessage(tripId: ResetTripMessage.tripA))),
            button(GlanceCopy.resetTripB, () => _send(const ResetTripMessage(tripId: ResetTripMessage.tripB))),
          ],
        ),
        const SizedBox(height: NightRoadSpacing.sm),
        Row(spacing: NightRoadSpacing.sm, children: [button(GlanceCopy.setOdometer, () => setState(() => _entry = _Entry.odometer), primary: true), button(GlanceCopy.setNextService, () => setState(() => _entry = _Entry.service))]),
      ],
    );
  }
}
