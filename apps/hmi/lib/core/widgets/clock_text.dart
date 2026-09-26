import 'dart:async';

import 'package:flutter/widgets.dart';

import '../format/glance_format.dart';

class ClockText extends StatefulWidget {
  const ClockText({super.key, this.format = GlanceFormat.clock, required this.style});

  final String Function(DateTime time) format;

  final TextStyle style;

  @override
  State<ClockText> createState() => _ClockTextState();
}

class _ClockTextState extends State<ClockText> {
  static const Duration refresh = Duration(seconds: 1);

  DateTime _now = DateTime.now();

  Timer? _timer;

  void _tick() {
    final now = DateTime.now();
    if (now.minute == _now.minute && now.hour == _now.hour) return;
    setState(() => _now = now);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(refresh, (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(widget.format(_now), maxLines: 1, overflow: TextOverflow.ellipsis, style: widget.style);
}
