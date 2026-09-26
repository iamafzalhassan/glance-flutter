import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:night_road/night_road.dart';

import '../../core/copy/glance_copy.dart';
import '../../core/providers/display_providers.dart';
import 'sections/about_section.dart';
import 'sections/calibration_section.dart';
import 'sections/display_section.dart';
import 'sections/odometer_section.dart';
import 'sections/signal_test_section.dart';

enum SettingsSection { display, odometer, calibration, signals, about }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const double listWidth = 264;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SettingsSection _section = SettingsSection.display;

  String _title(SettingsSection section) => switch (section) {
    SettingsSection.display => GlanceCopy.display,
    SettingsSection.odometer => GlanceCopy.odometerAndTrips,
    SettingsSection.calibration => GlanceCopy.calibration,
    SettingsSection.signals => GlanceCopy.signalTest,
    SettingsSection.about => GlanceCopy.about,
  };

  Widget _detail(SettingsSection section) => switch (section) {
    SettingsSection.display => const DisplaySection(key: ValueKey(SettingsSection.display)),
    SettingsSection.odometer => const OdometerSection(key: ValueKey(SettingsSection.odometer)),
    SettingsSection.calibration => const CalibrationSection(key: ValueKey(SettingsSection.calibration)),
    SettingsSection.signals => const SignalTestSection(key: ValueKey(SettingsSection.signals)),
    SettingsSection.about => const AboutSection(key: ValueKey(SettingsSection.about)),
  };

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        width: SettingsScreen.listWidth,
        child: NightRoadModule(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: NightRoadSpacing.xs,
            children: [
              Row(
                spacing: NightRoadSpacing.md,
                children: [
                  NightRoadRoundButton(icon: Icons.arrow_back_rounded, onPressed: ref.read(hmiSurfaceProvider.notifier).close, size: NightRoadSpacing.touch),
                  Expanded(
                    child: Text(
                      GlanceCopy.settings,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.title.copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NightRoadSpacing.md),
              for (final section in SettingsSection.values) _SectionTile(label: _title(section), onTap: () => setState(() => _section = section), selected: section == _section),
            ],
          ),
        ),
      ),
      const SizedBox(width: NightRoadSpacing.gutter),
      Expanded(
        child: NightRoadModule(
          child: AnimatedSwitcher(
            duration: NightRoadMotion.of(context, NightRoadMotion.quick),
            layoutBuilder: (current, previous) => Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
            switchInCurve: NightRoadMotion.quickCurve,
            switchOutCurve: NightRoadMotion.quickCurve,
            child: _detail(_section),
          ),
        ),
      ),
    ],
  );
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.selected, required this.label, required this.onTap});

  final bool selected;

  final String label;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return NightRoadPressable(
      onPressed: onTap,
      child: AnimatedContainer(
        alignment: Alignment.centerLeft,
        curve: NightRoadMotion.quickCurve,
        decoration: ShapeDecoration(color: selected ? colors.bgRaised : Colors.transparent, shape: NightRoadRadius.cardShape),
        duration: NightRoadMotion.of(context, NightRoadMotion.quick),
        height: NightRoadSpacing.touch,
        padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.lg),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: NightRoadType.body.copyWith(color: selected ? colors.textPrimary : colors.textSecondary),
        ),
      ),
    );
  }
}
