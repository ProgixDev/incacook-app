import 'package:incacook/core/services/map/models/map_route.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.mapboxId,
    required this.name,
    required this.placeFormatted,
    required this.featureType,
    this.fullAddress,
  });

  final String mapboxId;
  final String name;
  final String placeFormatted;
  final String? fullAddress;
  final String featureType;
}

//* Result of a /retrieve call. Has the full coordinate, billable in the
//* Search Box session model.
class RetrievedPlace {
  const RetrievedPlace({
    required this.mapboxId,
    required this.name,
    required this.placeFormatted,
    required this.coordinate,
    this.fullAddress,
  });

  final String mapboxId;
  final String name;
  final String placeFormatted;
  final MapPoint coordinate;
  final String? fullAddress;
}
