import 'package:flutter/foundation.dart';

import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/services/map/models/place_suggestion.dart';

/// Builds a complete [Address] from a Mapbox [RetrievedPlace].
///
/// Guarantees the displayed `fullAddress` is the WHOLE address (street +
/// postal + city + country), e.g. `"12 Rue Victor Hugo, 75001 Paris, France"`,
/// never just the street (`"Rue Victor Hugo"`). City + postcode come from
/// Mapbox's structured `context` first (locale-independent), with a fallback
/// parse of the FR "12345 City" formatted string when Mapbox omits them.
///
/// Used by every address picker (seller onboarding, pickup, client/delivery)
/// so the rule is identical everywhere. Logs only field-presence flags — never
/// the address values themselves.
Address addressFromRetrievedPlace(RetrievedPlace place) {
  final formatted = place.fullAddress ?? place.placeFormatted;

  var postal = place.postcode?.trim() ?? '';
  var city = place.city?.trim() ?? '';

  if (postal.isEmpty) {
    postal = RegExp(r'\b(\d{5})\b').firstMatch(formatted)?.group(1) ?? '';
  }
  if (city.isEmpty && postal.isNotEmpty) {
    final segments = formatted.split(',').map((s) => s.trim()).toList();
    city = segments
        .firstWhere((s) => s.startsWith(postal), orElse: () => '')
        .replaceFirst(postal, '')
        .trim();
  }

  final street =
      place.name.trim().isNotEmpty ? place.name.trim() : place.placeFormatted.trim();

  final fullAddress = composeFullAddress(
    fullAddress: place.fullAddress,
    street: street,
    postalCode: postal,
    city: city,
    country: place.country,
    placeFormatted: place.placeFormatted,
  );

  // Safe debug — presence flags only, no address values.
  debugPrint('[Address] selected full address exists: ${fullAddress.isNotEmpty}');
  debugPrint('[Address] city exists: ${city.isNotEmpty}');
  debugPrint('[Address] postalCode exists: ${postal.isNotEmpty}');

  return Address(
    fullAddress: fullAddress,
    city: city,
    postalCode: postal,
    coordinate: place.coordinate,
  );
}

/// Composes the most complete address string we can. Prefers Mapbox's own
/// `full_address`; otherwise reconstructs `street, "postal city", country`
/// so the city is never dropped. Falls back to `place_formatted` / street when
/// little structured data is available.
String composeFullAddress({
  String? fullAddress,
  required String street,
  String? postalCode,
  String? city,
  String? country,
  String? placeFormatted,
}) {
  final full = fullAddress?.trim() ?? '';
  if (full.isNotEmpty) return full;

  final cityLine = [postalCode ?? '', city ?? '']
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(' ');

  final parts = [street.trim(), cityLine, (country ?? '').trim()]
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isNotEmpty) return parts.join(', ');

  final pf = (placeFormatted ?? '').trim();
  return pf.isNotEmpty ? pf : street.trim();
}
