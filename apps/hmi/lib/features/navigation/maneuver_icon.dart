import 'package:flutter/material.dart';
import 'package:glance_maps/glance_maps.dart';

extension ManeuverIcon on Maneuver {
  IconData get icon => switch (this) {
    Maneuver.straight => Icons.straight_rounded,
    Maneuver.slightLeft => Icons.turn_slight_left_rounded,
    Maneuver.turnLeft => Icons.turn_left_rounded,
    Maneuver.sharpLeft => Icons.turn_sharp_left_rounded,
    Maneuver.uTurnLeft => Icons.u_turn_left_rounded,
    Maneuver.slightRight => Icons.turn_slight_right_rounded,
    Maneuver.turnRight => Icons.turn_right_rounded,
    Maneuver.sharpRight => Icons.turn_sharp_right_rounded,
    Maneuver.uTurnRight => Icons.u_turn_right_rounded,
    Maneuver.roundaboutLeft => Icons.roundabout_left_rounded,
    Maneuver.roundaboutRight => Icons.roundabout_right_rounded,
    Maneuver.forkLeft => Icons.fork_left_rounded,
    Maneuver.forkRight => Icons.fork_right_rounded,
    Maneuver.rampLeft => Icons.ramp_left_rounded,
    Maneuver.rampRight => Icons.ramp_right_rounded,
    Maneuver.merge => Icons.merge_rounded,
    Maneuver.arrive => Icons.flag_rounded,
  };
}
