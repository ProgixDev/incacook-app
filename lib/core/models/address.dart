import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/services/map/models/map_route.dart';

/// Saved-address category used to label home / work / other entries.
/// Null on one-off addresses captured during signup or ad-hoc checkout.
enum SavedAddressType {
  home(label: AppTexts.addressTypeHome, icon: Iconsax.home_2),
  work(label: AppTexts.addressTypeWork, icon: Iconsax.briefcase),
  other(label: AppTexts.addressTypeOther, icon: Iconsax.location);

  const SavedAddressType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// A user-supplied or geocoded address. Same shape across the signup flow,
/// the saved-addresses sheet, and checkout.
///
/// - [id] is null for in-flight pickers; the backend assigns one on save.
/// - [type] / [customLabel] only matter for saved addresses.
/// - [inRange] is a transient UI flag (out-of-range for the active seller's
///   delivery radius). It is not part of the persisted shape — set by the
///   list builder when displaying.
class Address {
  const Address({
    required this.fullAddress,
    required this.city,
    required this.postalCode,
    this.coordinate,
    this.id,
    this.type,
    this.customLabel,
    this.apartment,
    this.floor,
    this.digicode,
    this.deliveryNotes,
    this.inRange = true,
  });

  final String? id;
  final SavedAddressType? type;
  final String? customLabel;

  final String fullAddress;
  final String city;
  final String postalCode;
  // Geocoded position. Required at the persistence boundary, but optional
  // here so signup pickers and mock data can construct rows before the
  // geocoder resolves a point.
  final MapPoint? coordinate;

  final String? apartment;
  final String? floor;
  final String? digicode;
  final String? deliveryNotes;

  final bool inRange;

  String get line1 => fullAddress;
  String get line2 => '$postalCode $city'.trim();
  String get label => customLabel ?? type?.label ?? line1;

  Address copyWith({
    String? id,
    SavedAddressType? type,
    String? customLabel,
    String? fullAddress,
    String? city,
    String? postalCode,
    MapPoint? coordinate,
    String? apartment,
    String? floor,
    String? digicode,
    String? deliveryNotes,
    bool? inRange,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      customLabel: customLabel ?? this.customLabel,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      coordinate: coordinate ?? this.coordinate,
      apartment: apartment ?? this.apartment,
      floor: floor ?? this.floor,
      digicode: digicode ?? this.digicode,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      inRange: inRange ?? this.inRange,
    );
  }
}
