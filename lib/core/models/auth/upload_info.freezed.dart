// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadInfo {

 String get uploadUrl; String get token; String get path; String get bucket;
/// Create a copy of UploadInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadInfoCopyWith<UploadInfo> get copyWith => _$UploadInfoCopyWithImpl<UploadInfo>(this as UploadInfo, _$identity);

  /// Serializes this UploadInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadInfo&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.token, token) || other.token == token)&&(identical(other.path, path) || other.path == path)&&(identical(other.bucket, bucket) || other.bucket == bucket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uploadUrl,token,path,bucket);

@override
String toString() {
  return 'UploadInfo(uploadUrl: $uploadUrl, token: $token, path: $path, bucket: $bucket)';
}


}

/// @nodoc
abstract mixin class $UploadInfoCopyWith<$Res>  {
  factory $UploadInfoCopyWith(UploadInfo value, $Res Function(UploadInfo) _then) = _$UploadInfoCopyWithImpl;
@useResult
$Res call({
 String uploadUrl, String token, String path, String bucket
});




}
/// @nodoc
class _$UploadInfoCopyWithImpl<$Res>
    implements $UploadInfoCopyWith<$Res> {
  _$UploadInfoCopyWithImpl(this._self, this._then);

  final UploadInfo _self;
  final $Res Function(UploadInfo) _then;

/// Create a copy of UploadInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadUrl = null,Object? token = null,Object? path = null,Object? bucket = null,}) {
  return _then(_self.copyWith(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadInfo].
extension UploadInfoPatterns on UploadInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadInfo value)  $default,){
final _that = this;
switch (_that) {
case _UploadInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UploadInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uploadUrl,  String token,  String path,  String bucket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadInfo() when $default != null:
return $default(_that.uploadUrl,_that.token,_that.path,_that.bucket);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uploadUrl,  String token,  String path,  String bucket)  $default,) {final _that = this;
switch (_that) {
case _UploadInfo():
return $default(_that.uploadUrl,_that.token,_that.path,_that.bucket);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uploadUrl,  String token,  String path,  String bucket)?  $default,) {final _that = this;
switch (_that) {
case _UploadInfo() when $default != null:
return $default(_that.uploadUrl,_that.token,_that.path,_that.bucket);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadInfo implements UploadInfo {
  const _UploadInfo({required this.uploadUrl, required this.token, required this.path, required this.bucket});
  factory _UploadInfo.fromJson(Map<String, dynamic> json) => _$UploadInfoFromJson(json);

@override final  String uploadUrl;
@override final  String token;
@override final  String path;
@override final  String bucket;

/// Create a copy of UploadInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadInfoCopyWith<_UploadInfo> get copyWith => __$UploadInfoCopyWithImpl<_UploadInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadInfo&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.token, token) || other.token == token)&&(identical(other.path, path) || other.path == path)&&(identical(other.bucket, bucket) || other.bucket == bucket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uploadUrl,token,path,bucket);

@override
String toString() {
  return 'UploadInfo(uploadUrl: $uploadUrl, token: $token, path: $path, bucket: $bucket)';
}


}

/// @nodoc
abstract mixin class _$UploadInfoCopyWith<$Res> implements $UploadInfoCopyWith<$Res> {
  factory _$UploadInfoCopyWith(_UploadInfo value, $Res Function(_UploadInfo) _then) = __$UploadInfoCopyWithImpl;
@override @useResult
$Res call({
 String uploadUrl, String token, String path, String bucket
});




}
/// @nodoc
class __$UploadInfoCopyWithImpl<$Res>
    implements _$UploadInfoCopyWith<$Res> {
  __$UploadInfoCopyWithImpl(this._self, this._then);

  final _UploadInfo _self;
  final $Res Function(_UploadInfo) _then;

/// Create a copy of UploadInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadUrl = null,Object? token = null,Object? path = null,Object? bucket = null,}) {
  return _then(_UploadInfo(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
