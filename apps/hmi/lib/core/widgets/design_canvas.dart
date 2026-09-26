import 'package:flutter/widgets.dart';

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child});

  static const double designWidth = 1024;

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.biggest.isEmpty
        ? const SizedBox.shrink()
        : FittedBox(
            child: SizedBox(height: designWidth * constraints.maxHeight / constraints.maxWidth, width: designWidth, child: child),
          ),
  );
}
