// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_extra_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingExtraRequest _$ListingExtraRequestFromJson(Map<String, dynamic> json) =>
    _ListingExtraRequest(
      label: json['label'] as String,
      priceDeltaCents: (json['priceDeltaCents'] as num).toInt(),
      isSelectedByDefault: json['isSelectedByDefault'] as bool?,
    );

Map<String, dynamic> _$ListingExtraRequestToJson(
  _ListingExtraRequest instance,
) => <String, dynamic>{
  'label': instance.label,
  'priceDeltaCents': instance.priceDeltaCents,
  'isSelectedByDefault': ?instance.isSelectedByDefault,
};
