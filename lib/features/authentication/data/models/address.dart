/// User-supplied address. Fields are populated from a geocoding response
/// in production; the signup flow currently uses a stubbed picker.
class Address {
  const Address({
    required this.fullAddress,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.apartment,
    this.floor,
    this.digicode,
    this.deliveryNotes,
  });

  final String fullAddress;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? apartment;
  final String? floor;
  final String? digicode;
  final String? deliveryNotes;

  Address copyWith({
    String? fullAddress,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? apartment,
    String? floor,
    String? digicode,
    String? deliveryNotes,
  }) {
    return Address(
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      apartment: apartment ?? this.apartment,
      floor: floor ?? this.floor,
      digicode: digicode ?? this.digicode,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }
}
