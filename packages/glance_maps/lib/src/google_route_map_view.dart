import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'geo_point.dart';
import 'map_palette.dart';
import 'map_styles.dart';
import 'rider_arrow.dart';

class GoogleRouteMapView extends StatefulWidget {
  const GoogleRouteMapView({super.key, required this.night, required this.bearing, required this.ahead, required this.routeColor, required this.centre, this.rider});

  final bool night;

  final double bearing;

  final List<GeoPoint> ahead;

  final Color routeColor;

  final GeoPoint centre;

  final GeoPoint? rider;

  @override
  State<GoogleRouteMapView> createState() => _GoogleRouteMapViewState();
}

class _GoogleRouteMapViewState extends State<GoogleRouteMapView> {
  static const double tilt = 45;
  static const double zoom = 16.5;

  static const int routeWidth = 8;

  static const MarkerId riderId = MarkerId('rider');

  static const Offset riderAnchor = Offset(0.5, 0.5);

  static const PolylineId routeId = PolylineId('route');

  BitmapDescriptor? _riderIcon;

  GoogleMapController? _controller;

  RiderArrow get _riderArrow => RiderArrow(fill: widget.routeColor, outline: (widget.night ? MapPalette.night : MapPalette.day).base);

  Future<void> _loadRiderIcon() async {
    final arrow = _riderArrow;
    final icon = await arrow.toBitmap(MediaQuery.devicePixelRatioOf(context));
    if (mounted && arrow == _riderArrow) setState(() => _riderIcon = icon);
  }

  void _onMapCreated(GoogleMapController controller) => _controller = controller;

  CameraPosition _camera() => CameraPosition(bearing: widget.bearing, target: _latLng(widget.rider ?? widget.centre), tilt: tilt, zoom: zoom);

  LatLng _latLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_loadRiderIcon());
  }

  @override
  void didUpdateWidget(covariant GoogleRouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rider != widget.rider || oldWidget.bearing != widget.bearing || oldWidget.centre != widget.centre) _controller?.moveCamera(CameraUpdate.newCameraPosition(_camera()));
    if (oldWidget.night != widget.night || oldWidget.routeColor != widget.routeColor) unawaited(_loadRiderIcon());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _riderIcon;
    final rider = widget.rider;
    return GoogleMap(
      compassEnabled: false,
      initialCameraPosition: _camera(),
      mapToolbarEnabled: false,
      markers: {if (icon != null && rider != null) Marker(anchor: riderAnchor, flat: true, icon: icon, markerId: riderId, position: _latLng(rider), rotation: widget.bearing)},
      myLocationButtonEnabled: false,
      onMapCreated: _onMapCreated,
      polylines: {
        if (widget.ahead.length > 1) Polyline(color: widget.routeColor, points: [for (final point in widget.ahead) _latLng(point)], polylineId: routeId, width: routeWidth),
      },
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      style: widget.night ? MapStyles.night : null,
      tiltGesturesEnabled: false,
      webCameraControlEnabled: false,
      webGestureHandling: WebGestureHandling.none,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
    );
  }
}
