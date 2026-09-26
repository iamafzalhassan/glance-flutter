import 'package:flutter/widgets.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';

class KeypadEntry extends StatefulWidget {
  const KeypadEntry({super.key, this.allowDecimal = false, required this.body, required this.unit, required this.validate, required this.onSubmit, required this.onCancel});

  final bool allowDecimal;

  final String body;
  final String unit;

  final String? Function(String value) validate;

  final ValueChanged<String> onSubmit;

  final VoidCallback onCancel;

  @override
  State<KeypadEntry> createState() => _KeypadEntryState();
}

class _KeypadEntryState extends State<KeypadEntry> {
  static const double keypadWidth = 300;

  static const int maxDigits = 7;

  String _value = '';

  String? _error;

  void _submit() {
    final error = widget.validate(_value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    widget.onSubmit(_value);
  }

  void _backspace() {
    if (_value.isEmpty) return;
    setState(() {
      _value = _value.substring(0, _value.length - 1);
      _error = null;
    });
  }

  void _append(String key) {
    if (_value.length >= maxDigits) return;
    if (key == NightRoadKeypad.decimalKey && _value.contains(key)) return;
    setState(() {
      _value += key;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: NightRoadSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      _value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.numLarge.copyWith(color: colors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: NightRoadSpacing.sm),
                  Text(
                    widget.unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NightRoadType.caption.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: NightRoadSpacing.sm),
              Text(
                _error ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.caption.copyWith(color: colors.stateWarn),
              ),
              const Spacer(),
              Row(
                spacing: NightRoadSpacing.sm,
                children: [
                  Expanded(
                    child: NightRoadButton(color: colors.bgRaised, foreground: colors.textPrimary, label: GlanceCopy.cancel, onPressed: widget.onCancel),
                  ),
                  Expanded(
                    child: NightRoadButton(color: colors.textPrimary, label: GlanceCopy.save, onPressed: _submit),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: NightRoadSpacing.gutter),
        SizedBox(
          width: keypadWidth,
          child: Align(
            alignment: Alignment.topCenter,
            child: NightRoadKeypad(allowDecimal: widget.allowDecimal, onBackspace: _backspace, onKey: _append),
          ),
        ),
      ],
    );
  }
}
