// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateUploadRequest _$CreateUploadRequestFromJson(Map<String, dynamic> json) =>
    _CreateUploadRequest(
      purpose: $enumDecode(_$UploadPurposeEnumMap, json['purpose']),
      contentType: json['contentType'] as String?,
    );

Map<String, dynamic> _$CreateUploadRequestToJson(
  _CreateUploadRequest instance,
) => <String, dynamic>{
  'purpose': _$UploadPurposeEnumMap[instance.purpose]!,
  'contentType': ?instance.contentType,
};

const _$UploadPurposeEnumMap = {
  UploadPurpose.avatar: 'avatar',
  UploadPurpose.kycDocument: 'kyc_document',
  UploadPurpose.listingImage: 'listing_image',
  UploadPurpose.sellerFacade: 'seller_facade',
  UploadPurpose.deliveryProof: 'delivery_proof',
  UploadPurpose.disputeProof: 'dispute_proof',
};
