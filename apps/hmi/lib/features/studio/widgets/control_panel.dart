import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/telemetry_providers.dart';
import '../../navigation/navigation_providers.dart';
import '../../navigation/navigation_route.dart';

class ControlPanel extends ConsumerStatefulWidget {
  const ControlPanel({super.key});

  @override
  ConsumerState<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends ConsumerState<ControlPanel> {
  static const double maxBatteryMv = 14000;
  static const double maxCrcRate = 0.3;
  static const double maxDelayMs = 400;
  static const double maxJitterMs = 200;
  static const double maxPercent = 100;
  static const double maxSpeedKmh = 110;
  static const double maxSpikeRate = 0.2;
  static const double minBatteryMv = 10000;

  static const int batterySteps = 20;
  static const int crcSteps = 6;
  static const int delaySteps = 8;
  static const int fuelSteps = 10;
  static const int jitterSteps = 8;
  static const int speedSteps = 11;
  static const int spikeSteps = 4;

  static const Duration unplugFor = Duration(seconds: 3);

  void _toggleNavigation(bool enabled) {
    final navigation = ref.read(navigationSessionProvider.notifier);
    enabled ? navigation.start(NavigationRoute.saved.first) : navigation.stop();
  }

  Widget _switch(String label, bool value, ValueChanged<bool> change) => _SwitchRow(label: label, onChanged: (next) => setState(() => change(next)), value: value);

  Widget _slider(String label, double max, int divisions, double value, String Function(double value) format, ValueChanged<double> change, {double min = 0}) =>
      _SliderRow(divisions: divisions, format: format, label: label, max: max, min: min, onChanged: (next) => setState(() => change(next)), value: value);

  @override
  Widget build(BuildContext context) {
    final simulator = ref.watch(simulatorProvider);
    final bike = simulator.bike;
    final faults = simulator.faults;
    return ListView(
      padding: const EdgeInsets.all(NightRoadSpacing.lg),
      children: [
        _Section(
          title: GlanceCopy.studioControls,
          children: [
            _SwitchRow(label: GlanceCopy.studioNavigation, onChanged: _toggleNavigation, value: ref.watch(navigationSessionProvider) != null),
            _slider(GlanceCopy.studioSpeed, maxSpeedKmh, speedSteps, bike.targetSpeedKmh, (value) => '${value.round()} ${GlanceCopy.kmh}', (value) => bike.targetSpeedKmh = value),
            _slider(GlanceCopy.studioFuel, maxPercent, fuelSteps, bike.fuelPercent, (value) => GlanceCopy.percent(value.round()), (value) => bike.fuelPercent = value),
            _slider(GlanceCopy.studioBattery, maxBatteryMv, batterySteps, bike.batteryMv, (value) => GlanceCopy.volts(value.round()), (value) => bike.batteryMv = value, min: minBatteryMv),
            _switch(GlanceCopy.studioIgnition, bike.ignition, (value) => bike.ignition = value),
            _switch(GlanceCopy.studioStopStart, bike.stopStartSwitch, (value) => bike.stopStartSwitch = value),
            _switch(GlanceCopy.studioLeft, bike.leftSwitch, (value) => bike.leftSwitch = value),
            _switch(GlanceCopy.studioRight, bike.rightSwitch, (value) => bike.rightSwitch = value),
            _switch(GlanceCopy.studioHighBeam, bike.highBeam, (value) => bike.highBeam = value),
            _switch(GlanceCopy.studioFiWarning, bike.fiWarning, (value) => bike.fiWarning = value),
            _switch(GlanceCopy.studioSideStand, bike.sideStand, (value) => bike.sideStand = value),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: NightRoadSpacing.lg),
          child: NightRoadDivider(axis: Axis.horizontal, dotted: true),
        ),
        _Section(
          title: GlanceCopy.studioFaults,
          children: [
            _switch(GlanceCopy.studioDropout, faults.dropout, (value) => faults.dropout = value),
            _switch(GlanceCopy.studioFuelSlosh, faults.fuelSlosh, (value) => faults.fuelSlosh = value),
            _slider(GlanceCopy.studioDelay, maxDelayMs, delaySteps, faults.delay.inMilliseconds.toDouble(), (value) => GlanceCopy.milliseconds(value.round()), (value) => faults.delay = Duration(milliseconds: value.round())),
            _slider(GlanceCopy.studioJitter, maxJitterMs, jitterSteps, faults.jitter.inMilliseconds.toDouble(), (value) => GlanceCopy.milliseconds(value.round()), (value) => faults.jitter = Duration(milliseconds: value.round())),
            _slider(GlanceCopy.studioCrcErrors, maxCrcRate, crcSteps, faults.crcErrorRate, (value) => GlanceCopy.percent((value * maxPercent).round()), (value) => faults.crcErrorRate = value),
            _slider(GlanceCopy.studioSpikes, maxSpikeRate, spikeSteps, faults.spikeRate, (value) => GlanceCopy.percent((value * maxPercent).round()), (value) => faults.spikeRate = value),
            Wrap(
              runSpacing: NightRoadSpacing.md,
              spacing: NightRoadSpacing.sm,
              children: [
                _ActionButton(label: GlanceCopy.studioBimReboot, onPressed: simulator.rebootBim),
                _ActionButton(label: GlanceCopy.studioUnplug, onPressed: () => simulator.unplug(unplugFor)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: NightRoadSpacing.md,
    children: [
      _ToolText(color: context.colors.textPrimary, style: NightRoadType.toolHeading, text: title),
      ...children,
    ],
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.value, required this.label, required this.onChanged});

  final bool value;

  final String label;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: NightRoadSpacing.xl,
    child: Row(
      children: [
        Expanded(
          child: _ToolText(color: context.colors.textSecondary, text: label),
        ),
        FittedBox(
          child: CupertinoSwitch(activeTrackColor: context.colors.stateEco, onChanged: onChanged, value: value),
        ),
      ],
    ),
  );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({required this.divisions, required this.max, this.min = 0, required this.value, required this.label, required this.format, required this.onChanged});

  final int divisions;

  final double max;
  final double min;
  final double value;

  final String label;

  final String Function(double value) format;

  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: NightRoadSpacing.xl,
          child: Row(
            children: [
              Expanded(
                child: _ToolText(color: colors.textSecondary, text: label),
              ),
              _ToolText(color: colors.textMuted, text: format(value)),
            ],
          ),
        ),
        NightRoadSlider(divisions: divisions, label: format, labelStyle: NightRoadType.toolLabel, max: max, min: min, onChanged: onChanged, value: value),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CupertinoButton(
    color: context.colors.bgRaised,
    onPressed: onPressed,
    sizeStyle: CupertinoButtonSize.small,
    child: _ToolText(color: context.colors.textPrimary, text: label),
  );
}

class _ToolText extends StatelessWidget {
  const _ToolText({required this.text, required this.color, this.style = NightRoadType.toolLabel});

  final String text;

  final Color color;

  final TextStyle style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: style.copyWith(color: color),
  );
}
