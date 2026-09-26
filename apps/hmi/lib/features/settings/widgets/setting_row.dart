import 'package:flutter/widgets.dart';
import 'package:night_road/night_road.dart';

class SettingRow extends StatelessWidget {
  const SettingRow({super.key, required this.label, required this.trailing});

  final String label;

  final Widget trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: NightRoadSpacing.touch,
    child: Row(
      children: [
        Expanded(child: NightRoadLabel(label)),
        trailing,
      ],
    ),
  );
}
