import 'dart:math';

import 'package:flutter/material.dart';
import 'package:night_road/night_road.dart';

import '../hmi/hmi_root.dart';
import 'widgets/control_panel.dart';
import 'widgets/device_frame.dart';

class StudioShell extends StatelessWidget {
  const StudioShell({super.key});

  static const double _minGap = NightRoadSpacing.xl;
  static const double _panelWidth = 300;

  static const Size _deviceSize = Size(1024, 600);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.bgBase,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final panelWidth = min(_panelWidth, constraints.maxWidth);
          final fitHeight = max(0.0, constraints.maxHeight - _minGap * 2) * _deviceSize.aspectRatio;
          final deviceWidth = max(0.0, min(constraints.maxWidth - panelWidth - _minGap * 3, fitHeight));
          final gap = max(0.0, (constraints.maxWidth - panelWidth - deviceWidth) / 3);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: gap),
            child: Row(
              children: [
                SizedBox(
                  width: deviceWidth,
                  child: const Center(
                    child: DeviceFrame(size: _deviceSize, child: HmiRoot()),
                  ),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: panelWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: _minGap),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(color: context.colors.bgPanel, shape: NightRoadRadius.panelShape),
                      child: const ClipRSuperellipse(borderRadius: NightRoadRadius.panelAll, child: ControlPanel()),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
