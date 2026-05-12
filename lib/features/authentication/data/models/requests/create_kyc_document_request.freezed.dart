// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_kyc_document_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateKycDocumentRequest {

 KycDocumentType get type; String get fileUrl;// /v1/uploads path
 IdDocumentType? get idDocumentType;
/// Create a copy of CreateKycDocumentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateKycDocumentRequestCopyWith<CreateKycDocumentRequest> get copyWith => _$CreateKycDocumentRequestCopyWithImpl<CreateKycDocumentRequest>(this as CreateKycDocumentRequest, _$identity);

  /// Serializes this CreateKycDocumentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateKycDocumentRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.idDocumentType, idDocumentType) || other.idDocumentType == idDocumentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,fileUrl,idDocumentType);

@override
String toString() {
  return 'CreateKycDocumentRequest(type: $type, fileUrl: $fileUrl, idDocumentType: $idDocumentType)';
}


}

/// @nodoc
abstract mixin class $CreateKycDocumentRequestCopyWith<$Res>  {
  factory $CreateKycDocumentRequestCopyWith(CreateKycDocumentRequest value, $Res Function(CreateKycDocumentRequest) _then) = _$CreateKycDocumentRequestCopyWithImpl;
@useResult
$Res call({
 KycDocumentType type, String fileUrl, IdDocumentType? idDocumentType
});




}
/// @nodoc
class _$CreateKycDocumentRequestCopyWithImpl<$Res>
    implements $CreateKycDocumentRequestCopyWith<$Res> {
  _$CreateKycDocumentRequestCopyWithImpl(this._self, this._then);

  final CreateKycDocumentRequest _self;
  final $Res Function(CreateKycDocumentRequest) _then;

/// Create a copy of CreateKycDocumentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? fileUrl = null,Object? idDocumentType = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KycDocumentType,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,idDocumentType: freezed == idDocumentType ? _self.idDocumentType : idDocumentType // ignore: cast_nullable_to_non_nullable
as IdDocumentType?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateKycDocumentRequest].
extension CreateKycDocumentRequestPatterns on CreateKycDocumentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateKycDocumentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateKycDocumentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateKycDocumentRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateKycDocumentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateKycDocumentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateKycDocumentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KycDocumentType type,  String fileUrl,  IdDocumentType? idDocumentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateKycDocumentRequest() when $default != null:
return $default(_that.type,_that.fileUrl,_that.idDocumentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KycDocumentType type,  String fileUrl,  IdDocumentType? idDocumentType)  $default,) {final _that = this;
switch (_that) {
case _CreateKycDocumentRequest():
return $default(_that.type,_that.fileUrl,_that.idDocumentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KycDocumentType type,  String fileUrl,  IdDocumentType? idDocumentType)?  $default,) {final _that = this;
switch (_that) {
case _CreateKycDocumentRequest() when $default != null:
return $default(_that.type,_that.fileUrl,_that.idDocumentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateKycDocumentRequest implements CreateKycDocumentRequest {
  const _CreateKycDocumentRequest({required this.type, required this.fileUrl, this.idDocumentType});
  factory _CreateKycDocumentRequest.fromJson(Map<String, dynamic> json) => _$CreateKycDocumentRequestFromJson(json);

@override final  KycDocumentType type;
@override final  String fileUrl;
// /v1/uploads path
@override final  IdDocumentType? idDocumentType;

/// Create a copy of CreateKycDocumentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateKycDocumentRequestCopyWith<_CreateKycDocumentRequest> get copyWith => __$CreateKycDocumentRequestCopyWithImpl<_CreateKycDocumentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateKycDocumentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateKycDocumentRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.idDocumentType, idDocumentType) || other.idDocumentType == idDocumentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,fileUrl,idDocumentType);

@override
String toString() {
  return 'CreateKycDocumentRequest(type: $type, fileUrl: $fileUrl, idDocumentType: $idDocumentType)';
}


}

/// @nodoc
abstract mixin class _$CreateKycDocumentRequestCopyWith<$Res> implements $CreateKycDocumentRequestCopyWith<$Res> {
  factory _$CreateKycDocumentRequestCopyWith(_CreateKycDocumentRequest value, $Res Function(_CreateKycDocumentRequest) _then) = __$CreateKycDocumentRequestCopyWithImpl;
@override @useResult
$Res call({
 KycDocumentType type, String fileUrl, IdDocumentType? idDocumentType
});




}
/// @nodoc
class __$CreateKycDocumentRequestCopyWithImpl<$Res>
    implements _$CreateKycDocumentRequestCopyWith<$Res> {
  __$CreateKycDocumentRequestCopyWithImpl(this._self, this._then);

  final _CreateKycDocumentRequest _self;
  final $Res Function(_CreateKycDocumentRequest) _then;

/// Create a copy of CreateKycDocumentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? fileUrl = null,Object? idDocumentType = freezed,}) {
  return _then(_CreateKycDocumentRequest(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KycDocumentType,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,idDocumentType: freezed == idDocumentType ? _self.idDocumentType : idDocumentType // ignore: cast_nullable_to_non_nullable
as IdDocumentType?,
  ));
}


}

// dart format on
