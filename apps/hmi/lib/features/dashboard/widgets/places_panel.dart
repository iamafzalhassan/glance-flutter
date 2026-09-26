import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glance_maps/glance_maps.dart';
import 'package:night_road/night_road.dart';

import '../../../core/copy/glance_copy.dart';
import '../../../core/providers/display_providers.dart';
import '../../../core/providers/map_providers.dart';
import '../../navigation/navigation_providers.dart';
import '../../navigation/navigation_route.dart';

class PlacesPanel extends ConsumerStatefulWidget {
  const PlacesPanel({super.key});

  @override
  ConsumerState<PlacesPanel> createState() => _PlacesPanelState();
}

class _PlacesPanelState extends ConsumerState<PlacesPanel> {
  static const int minQuery = 3;

  static const Duration debounce = Duration(milliseconds: 400);

  final TextEditingController _query = TextEditingController();

  bool _searching = false;

  int _searchId = 0;

  List<Place> _places = const [];

  String? _error;
  String? _routingId;

  Timer? _debounce;

  GeoPoint get _near => ref.read(riderLocationProvider).value?.position ?? defaultMapCentre;

  void _onQueryChanged() {
    _debounce?.cancel();
    final query = _query.text.trim();
    setState(() {
      _error = null;
      if (query.length < minQuery) _places = const [];
    });
    if (query.length >= minQuery) _debounce = Timer(debounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    final client = await ref.read(mapsClientProvider.future);
    if (client == null || !mounted) return;
    final searchId = ++_searchId;
    setState(() => _searching = true);
    try {
      final places = await client.searchPlaces(query, _near);
      if (mounted && searchId == _searchId) setState(() => _places = places);
    } catch (_) {
      if (mounted && searchId == _searchId) setState(() => _error = GlanceCopy.searchFailed);
    }
    if (mounted && searchId == _searchId) setState(() => _searching = false);
  }

  Future<void> _navigate(Place place) async {
    setState(() {
      _error = null;
      _routingId = place.id;
    });
    try {
      await ref.read(navigationSessionProvider.notifier).startTo(place);
      if (mounted) ref.read(hmiSurfaceProvider.notifier).close();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = GlanceCopy.routeFailed;
          _routingId = null;
        });
      }
    }
  }

  void _startSaved(NavigationRoute route) {
    ref.read(navigationSessionProvider.notifier).start(route);
    ref.read(hmiSurfaceProvider.notifier).close();
  }

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final google = ref.watch(mapsClientProvider).value != null;
    final query = _query.text.trim().toLowerCase();
    final saved = [
      for (final route in NavigationRoute.saved)
        if (query.isEmpty || route.destination.toLowerCase().contains(query)) route,
    ];
    final message = _error ?? (google ? (query.length < minQuery ? GlanceCopy.searchHint : (_places.isEmpty && !_searching ? GlanceCopy.noPlaces : null)) : (saved.isEmpty ? GlanceCopy.noPlaces : null));
    return DecoratedBox(
      decoration: ShapeDecoration(color: colors.bgPanel, shape: NightRoadRadius.cardShape),
      child: Padding(
        padding: const EdgeInsets.all(NightRoadSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: NightRoadLabel(GlanceCopy.search)),
                NightRoadRoundButton(icon: Icons.close_rounded, onPressed: ref.read(hmiSurfaceProvider.notifier).close, size: NightRoadSpacing.touch),
              ],
            ),
            const SizedBox(height: NightRoadSpacing.sm),
            CupertinoSearchTextField(
              autofocus: true,
              backgroundColor: colors.bgRaised,
              borderRadius: NightRoadRadius.cardAll,
              controller: _query,
              itemColor: colors.textMuted,
              itemSize: NightRoadSpacing.icon,
              padding: const EdgeInsets.symmetric(horizontal: NightRoadSpacing.sm, vertical: NightRoadSpacing.lg),
              placeholder: GlanceCopy.search,
              placeholderStyle: NightRoadType.body.copyWith(color: colors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded),
              prefixInsets: const EdgeInsetsDirectional.only(start: NightRoadSpacing.md),
              style: NightRoadType.body.copyWith(color: colors.textPrimary),
              suffixIcon: const Icon(Icons.cancel_rounded),
              suffixInsets: const EdgeInsetsDirectional.only(end: NightRoadSpacing.md),
            ),
            const SizedBox(height: NightRoadSpacing.md),
            if (message != null)
              Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NightRoadType.body.copyWith(color: _error == null ? colors.textMuted : colors.stateWarn),
              ),
            Expanded(
              child: _searching
                  ? const Center(child: NightRoadLoader())
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: google
                          ? [
                              for (final place in _places)
                                _PlaceTile(
                                  detail: place.address,
                                  loading: place.id == _routingId,
                                  onTap: _routingId == null ? () => _navigate(place) : null,
                                  title: place.name,
                                  trailing: GlanceCopy.distance(_near.distanceTo(place.location).round()),
                                ),
                            ]
                          : [for (final route in saved) _PlaceTile(detail: '', onTap: () => _startSaved(route), title: route.destination, trailing: GlanceCopy.distance(route.lengthM))],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({this.loading = false, required this.detail, required this.title, required this.trailing, required this.onTap});

  final bool loading;

  final String detail;
  final String title;
  final String trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return NightRoadPressable(
      onPressed: onTap,
      child: SizedBox(
        height: NightRoadSpacing.touch,
        child: Row(
          spacing: NightRoadSpacing.md,
          children: [
            Icon(Icons.place_rounded, color: colors.accentNav, size: NightRoadSpacing.icon),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NightRoadType.body.copyWith(color: colors.textPrimary),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NightRoadType.caption.copyWith(color: colors.textMuted),
                    ),
                ],
              ),
            ),
            if (loading) const NightRoadLoader() else Text(trailing, maxLines: 1, style: NightRoadType.caption.copyWith(color: colors.textMuted)),
          ],
        ),
      ),
    );
  }
}
