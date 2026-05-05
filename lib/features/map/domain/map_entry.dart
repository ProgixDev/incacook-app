import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:homemade/features/client/domain/food_listing.dart';

/// Bundle of a [FoodListing] with the geographic [Position] where it should
/// be pinned on the map. Lives in the map feature because the pairing only
/// matters for the map view.
class MapEntry {
  const MapEntry({required this.position, required this.listing});

  final Position position;
  final FoodListing listing;
}
