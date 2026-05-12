// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadInfo _$UploadInfoFromJson(Map<String, dynamic> json) => _UploadInfo(
  uploadUrl: json['upload_url'] as String,
  token: json['token'] as String,
  path: json['path'] as String,
  bucket: json['bucket'] as String,
);

Map<String, dynamic> _$UploadInfoToJson(_UploadInfo instance) =>
    <String, dynamic>{
      'upload_url': instance.uploadUrl,
      'token': instance.token,
      'path': instance.path,
      'bucket': instance.bucket,
    };
