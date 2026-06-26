import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/services/map/address_mapping.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/services/map/models/place_suggestion.dart';

RetrievedPlace _place({
  String name = '',
  String placeFormatted = '',
  String? fullAddress,
  String? city,
  String? postcode,
  String? country,
}) {
  return RetrievedPlace(
    mapboxId: 'id',
    name: name,
    placeFormatted: placeFormatted,
    fullAddress: fullAddress,
    city: city,
    postcode: postcode,
    country: country,
    coordinate: const MapPoint(lng: 2.3522, lat: 48.8566),
  );
}

void main() {
  group('addressFromRetrievedPlace', () {
    test('street + city + postal (Mapbox full_address) keeps the full address', () {
      final a = _place(
        name: '12 Rue Victor Hugo',
        fullAddress: '12 Rue Victor Hugo, 75001 Paris, France',
        city: 'Paris',
        postcode: '75001',
        country: 'France',
      );
      final address = addressFromRetrievedPlace(a);
      expect(address.fullAddress, '12 Rue Victor Hugo, 75001 Paris, France');
      expect(address.city, 'Paris');
      expect(address.postalCode, '75001');
    });

    test('no Mapbox full_address → reconstructs "street, postal city, country"', () {
      final address = addressFromRetrievedPlace(_place(
        name: '12 Rue Victor Hugo',
        placeFormatted: '75001 Paris, France',
        city: 'Paris',
        postcode: '75001',
        country: 'France',
      ));
      expect(address.fullAddress, '12 Rue Victor Hugo, 75001 Paris, France');
    });

    test('no street number → still includes city + postal (never street-only)', () {
      final address = addressFromRetrievedPlace(_place(
        name: 'Rue Victor Hugo',
        city: 'Paris',
        postcode: '75001',
        country: 'France',
      ));
      expect(address.fullAddress, 'Rue Victor Hugo, 75001 Paris, France');
      expect(address.fullAddress, contains('Paris'));
      expect(address.fullAddress, isNot('Rue Victor Hugo'));
    });

    test('city without postal → keeps city, omits empty postal', () {
      final address = addressFromRetrievedPlace(_place(
        name: '12 Rue Victor Hugo',
        city: 'Paris',
        country: 'France',
      ));
      expect(address.fullAddress, '12 Rue Victor Hugo, Paris, France');
      expect(address.city, 'Paris');
      expect(address.postalCode, '');
    });

    test('GPS reverse with structured context (no full_address) reconstructs fully', () {
      final address = addressFromRetrievedPlace(_place(
        name: '5 Avenue de la République',
        placeFormatted: '75011 Paris, France',
        city: 'Paris',
        postcode: '75011',
        country: 'France',
      ));
      expect(address.fullAddress, contains('Paris'));
      expect(address.fullAddress, contains('75011'));
      expect(address.city, 'Paris');
    });

    test('falls back to FR-postal parsing when context fields are missing', () {
      final address = addressFromRetrievedPlace(_place(
        name: '12 Rue X',
        fullAddress: '12 Rue X, 75011 Paris, France',
      ));
      expect(address.postalCode, '75011');
      expect(address.city, 'Paris');
      expect(address.fullAddress, '12 Rue X, 75011 Paris, France');
    });
  });

  group('composeFullAddress', () {
    test('manual entry: an explicit full address is kept verbatim', () {
      expect(
        composeFullAddress(
          fullAddress: '1 Rue A, 75001 Paris, France',
          street: 'ignored',
        ),
        '1 Rue A, 75001 Paris, France',
      );
    });

    test('reconstructs from parts when no full address is given', () {
      expect(
        composeFullAddress(
          street: '12 Rue Victor Hugo',
          postalCode: '75001',
          city: 'Paris',
          country: 'France',
        ),
        '12 Rue Victor Hugo, 75001 Paris, France',
      );
    });
  });
}
