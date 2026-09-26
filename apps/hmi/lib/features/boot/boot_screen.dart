import 'package:flutter/widgets.dart';
import 'package:night_road/night_road.dart';

import '../../core/brand/glance_brand.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> with SingleTickerProviderStateMixin {
  late final Animation<double> _progress = CurvedAnimation(curve: NightRoadMotion.bootCurve, parent: _controller);

  late final AnimationController _controller = AnimationController(duration: NightRoadMotion.boot, vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    _controller.duration = NightRoadMotion.of(context, NightRoadMotion.boot);
    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: FadeTransition(
      opacity: _progress,
      child: Image.asset(GlanceBrand.logo, color: context.colors.textPrimary, colorBlendMode: BlendMode.srcIn, height: NightRoadSpacing.logo, width: NightRoadSpacing.logo),
    ),
  );
}
