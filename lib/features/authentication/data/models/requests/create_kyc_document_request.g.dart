// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_kyc_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateKycDocumentRequest _$CreateKycDocumentRequestFromJson(
  Map<String, dynamic> json,
) => _CreateKycDocumentRequest(
  type: $enumDecode(_$KycDocumentTypeEnumMap, json['type']),
  fileUrl: json['file_url'] as String,
  idDocumentType: $enumDecodeNullable(
    _$IdDocumentTypeEnumMap,
    json['id_document_type'],
  ),
);

Map<String, dynamic> _$CreateKycDocumentRequestToJson(
  _CreateKycDocumentRequest instance,
) => <String, dynamic>{
  'type': _$KycDocumentTypeEnumMap[instance.type]!,
  'file_url': instance.fileUrl,
  'id_document_type': ?_$IdDocumentTypeEnumMap[instance.idDocumentType],
};

const _$KycDocumentTypeEnumMap = {
  KycDocumentType.idFront: 'ID_FRONT',
  KycDocumentType.idBack: 'ID_BACK',
  KycDocumentType.selfie: 'SELFIE',
  KycDocumentType.drivingLicense: 'DRIVING_LICENSE',
  KycDocumentType.carteGrise: 'CARTE_GRISE',
  KycDocumentType.insurance: 'INSURANCE',
};

const _$IdDocumentTypeEnumMap = {
  IdDocumentType.carteIdentite: 'CARTE_IDENTITE',
  IdDocumentType.passeport: 'PASSEPORT',
  IdDocumentType.titreSejour: 'TITRE_SEJOUR',
};
