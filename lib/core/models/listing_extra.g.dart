// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_extra.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingExtra _$ListingExtraFromJson(Map<String, dynamic> json) =>
    _ListingExtra(
      id: json['id'] as String,
      label: json['label'] as String,
      priceDeltaCents: (json['priceDeltaCents'] as num).toInt(),
      isSelectedByDefault: json['isSelectedByDefault'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ListingExtraToJson(_ListingExtra instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'priceDeltaCents': instance.priceDeltaCents,
      'isSelectedByDefault': instance.isSelectedByDefault,
      'sortOrder': instance.sortOrder,
    };
