import 'package:flutter/widgets.dart';

import '../night_road_context.dart';
import '../night_road_type.dart';

class NightRoadLabel extends StatelessWidget {
  const NightRoadLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: NightRoadType.body.copyWith(color: context.colors.textSecondary),
  );
}
