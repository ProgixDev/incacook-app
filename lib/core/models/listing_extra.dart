import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_extra.freezed.dart';
part 'listing_extra.g.dart';

/// Per-listing add-on declared by the seller (bread, drinks, sauces, …).
///
/// Lives inline on the [Listing] resource ([Listing.extras]). Replaced
/// wholesale on `PATCH /v1/listings/:id` when the request body carries
/// `extras` — see `flutter-listings-api.md` §5.2.
///
/// [priceDeltaCents] is a signed integer in cents: positive for "extra
/// cheese: +50¢", negative for "no olives: -50¢", zero for a free
/// option. Money lives in cents on the wire — convert to euros only at
/// display / form-input time.
@freezed
abstract class ListingExtra with _$ListingExtra {
  const factory ListingExtra({
    required String id,
    required String label,
    required int priceDeltaCents,
    @Default(false) bool isSelectedByDefault,
    @Default(0) int sortOrder,
  }) = _ListingExtra;

  factory ListingExtra.fromJson(Map<String, dynamic> json) =>
      _$ListingExtraFromJson(json);
}
