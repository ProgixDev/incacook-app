// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) => _KycDocument(
  id: json['id'] as String,
  type: $enumDecode(_$KycDocumentTypeEnumMap, json['type']),
  fileUrl: json['file_url'] as String,
  reviewState: $enumDecode(_$KycReviewStateEnumMap, json['review_state']),
  rejectionReason: json['rejection_reason'] as String?,
  submittedAt: json['submitted_at'] as String,
  reviewedAt: json['reviewed_at'] as String?,
  metadata: json['metadata'] == null
      ? null
      : KycDocumentMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KycDocumentToJson(_KycDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$KycDocumentTypeEnumMap[instance.type]!,
      'file_url': instance.fileUrl,
      'review_state': _$KycReviewStateEnumMap[instance.reviewState]!,
      'rejection_reason': ?instance.rejectionReason,
      'submitted_at': instance.submittedAt,
      'reviewed_at': ?instance.reviewedAt,
      'metadata': ?instance.metadata?.toJson(),
    };

const _$KycDocumentTypeEnumMap = {
  KycDocumentType.idFront: 'ID_FRONT',
  KycDocumentType.idBack: 'ID_BACK',
  KycDocumentType.selfie: 'SELFIE',
  KycDocumentType.drivingLicense: 'DRIVING_LICENSE',
  KycDocumentType.carteGrise: 'CARTE_GRISE',
  KycDocumentType.insurance: 'INSURANCE',
};

const _$KycReviewStateEnumMap = {
  KycReviewState.pending: 'PENDING',
  KycReviewState.approved: 'APPROVED',
  KycReviewState.rejected: 'REJECTED',
};

_KycDocumentMetadata _$KycDocumentMetadataFromJson(Map<String, dynamic> json) =>
    _KycDocumentMetadata(
      idDocumentType: $enumDecodeNullable(
        _$IdDocumentTypeEnumMap,
        json['id_document_type'],
      ),
    );

Map<String, dynamic> _$KycDocumentMetadataToJson(
  _KycDocumentMetadata instance,
) => <String, dynamic>{
  'id_document_type': ?_$IdDocumentTypeEnumMap[instance.idDocumentType],
};

const _$IdDocumentTypeEnumMap = {
  IdDocumentType.carteIdentite: 'CARTE_IDENTITE',
  IdDocumentType.passeport: 'PASSEPORT',
  IdDocumentType.titreSejour: 'TITRE_SEJOUR',
};
