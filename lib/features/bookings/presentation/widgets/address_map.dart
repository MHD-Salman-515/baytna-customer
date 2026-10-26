import 'dart:async';

import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap with a pin fixed at the centre: she drags the MAP until
/// the pin sits on her door (the usual pattern in ride-hailing apps, and
/// easier on a small screen than grabbing a small marker). A tap moves the
/// map there too. No Google Maps, no API key.
///
/// OSM's tile policy requires a real User-Agent and visible attribution;
/// both are set.
class AddressMap extends StatefulWidget {
  const AddressMap({
    required this.pin,
    required this.onPinMoved,
    required this.onLocateMe,
    this.locating = false,
    super.key,
  });

  /// Where the pin is. When this changes from outside (GPS fix), the map
  /// follows; drags report back through [onPinMoved].
  final GeoPoint pin;
  final ValueChanged<GeoPoint> onPinMoved;
  final VoidCallback onLocateMe;
  final bool locating;

  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgentPackageName = 'com.baytna.baytna_customer';

  @override
  State<AddressMap> createState() => _AddressMapState();
}

class _AddressMapState extends State<AddressMap> {
  final _controller = MapController();
  Timer? _debounce;
  GeoPoint? _reported;
  bool _ready = false;

  static LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  @override
  void didUpdateWidget(AddressMap old) {
    super.didUpdateWidget(old);
    // An outside move (e.g. "my location"), not the echo of her own drag.
    if (_ready && widget.pin != _reported && widget.pin != old.pin) {
      _controller.move(_latLng(widget.pin), _controller.camera.zoom);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onMoved(MapCamera camera) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final p = GeoPoint(latitude: camera.center.latitude, longitude: camera.center.longitude);
      _reported = p;
      widget.onPinMoved(p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            key: const ValueKey('address-map'),
            mapController: _controller,
            options: MapOptions(
              initialCenter: _latLng(widget.pin),
              initialZoom: 16,
              minZoom: 5,
              maxZoom: 19,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              onMapReady: () => _ready = true,
              onPositionChanged: (camera, _) => _onMoved(camera),
              onTap: (_, point) => _controller.move(point, _controller.camera.zoom),
            ),
            children: [
              TileLayer(urlTemplate: AddressMap.tileUrl, userAgentPackageName: AddressMap.userAgentPackageName),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),
          // The pin's tip is the map centre.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 44),
                child: Icon(Icons.location_on_rounded, key: const ValueKey('map-pin'), size: 48, color: scheme.error),
              ),
            ),
          ),
          PositionedDirectional(
            end: 12,
            top: 12,
            child: FloatingActionButton.small(
              key: const ValueKey('locate-me'),
              heroTag: null,
              tooltip: context.l10n.addressLocateMe,
              onPressed: widget.locating ? null : widget.onLocateMe,
              child: widget.locating
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
