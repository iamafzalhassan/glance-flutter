import 'package:flutter_test/flutter_test.dart';
import 'package:glance_maps/glance_maps.dart';

void main() {
  const route = {
    'distanceMeters': 2400,
    'duration': '420s',
    'polyline': {'encodedPolyline': '_p~iF~ps|U_ulLnnqC'},
    'legs': [
      {
        'steps': [
          {
            'distanceMeters': 1500,
            'navigationInstruction': {'instructions': 'Head north on Galle Rd', 'maneuver': 'DEPART'},
          },
          {
            'distanceMeters': 900,
            'navigationInstruction': {'instructions': 'Turn left onto Duplication Rd', 'maneuver': 'TURN_LEFT'},
          },
        ],
      },
    ],
  };

  test('reads distance, duration, path and every step of a Routes API route', () {
    final plan = RoutePlan.fromJson(route);
    expect(plan.distanceM, 2400);
    expect(plan.duration, const Duration(seconds: 420));
    expect(plan.path, hasLength(2));
    expect(plan.steps.map((step) => step.lengthM), [1500, 900]);
    expect(plan.steps.last.instruction, 'Turn left onto Duplication Rd');
  });

  test('maps Routes API maneuvers and treats unknown ones as straight on', () {
    final plan = RoutePlan.fromJson(route);
    expect(plan.steps.first.maneuver, Maneuver.straight);
    expect(plan.steps.last.maneuver, Maneuver.turnLeft);
  });

  test('reads a place from the Places API', () {
    final place = Place.fromJson({
      'displayName': {'text': 'Galle Face Green'},
      'formattedAddress': 'Colombo 00300',
      'id': 'abc',
      'location': {'latitude': 6.92, 'longitude': 79.84},
    });
    expect(place.name, 'Galle Face Green');
    expect(place.location, const GeoPoint(6.92, 79.84));
  });
}
