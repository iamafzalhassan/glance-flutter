import 'package:flutter/material.dart';

import '../night_road_context.dart';
import '../night_road_radius.dart';
import '../night_road_spacing.dart';
import '../night_road_type.dart';
import 'night_road_pressable.dart';

class NightRoadKeypad extends StatelessWidget {
  const NightRoadKeypad({super.key, this.allowDecimal = false, required this.onKey, required this.onBackspace});

  static const String decimalKey = '.';

  static const List<String> digitRows = ['123', '456', '789'];

  final bool allowDecimal;

  final ValueChanged<String> onKey;

  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: NightRoadSpacing.sm,
    children: [
      for (final row in digitRows)
        Row(
          spacing: NightRoadSpacing.sm,
          children: [for (final digit in row.split('')) _Key(onPressed: () => onKey(digit), child: _KeyLabel(digit))],
        ),
      Row(
        spacing: NightRoadSpacing.sm,
        children: [
          _Key(onPressed: allowDecimal ? () => onKey(decimalKey) : null, child: _KeyLabel(allowDecimal ? decimalKey : '')),
          _Key(onPressed: () => onKey('0'), child: const _KeyLabel('0')),
          _Key(
            onPressed: onBackspace,
            child: Icon(Icons.backspace_rounded, color: context.colors.textPrimary, size: NightRoadSpacing.icon),
          ),
        ],
      ),
    ],
  );
}

class _Key extends StatelessWidget {
  const _Key({required this.onPressed, required this.child});

  final VoidCallback? onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) => Expanded(
    child: NightRoadPressable(
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: onPressed == null ? null : context.colors.bgRaised, shape: NightRoadRadius.cardShape),
        child: SizedBox(
          height: NightRoadSpacing.touch,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class _KeyLabel extends StatelessWidget {
  const _KeyLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    style: NightRoadType.title.copyWith(color: context.colors.textPrimary, fontFeatures: NightRoadType.tabular),
  );
}
