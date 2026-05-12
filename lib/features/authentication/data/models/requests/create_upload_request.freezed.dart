// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateUploadRequest {

 UploadPurpose get purpose; String? get contentType;
/// Create a copy of CreateUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUploadRequestCopyWith<CreateUploadRequest> get copyWith => _$CreateUploadRequestCopyWithImpl<CreateUploadRequest>(this as CreateUploadRequest, _$identity);

  /// Serializes this CreateUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUploadRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,contentType);

@override
String toString() {
  return 'CreateUploadRequest(purpose: $purpose, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $CreateUploadRequestCopyWith<$Res>  {
  factory $CreateUploadRequestCopyWith(CreateUploadRequest value, $Res Function(CreateUploadRequest) _then) = _$CreateUploadRequestCopyWithImpl;
@useResult
$Res call({
 UploadPurpose purpose, String? contentType
});




}
/// @nodoc
class _$CreateUploadRequestCopyWithImpl<$Res>
    implements $CreateUploadRequestCopyWith<$Res> {
  _$CreateUploadRequestCopyWithImpl(this._self, this._then);

  final CreateUploadRequest _self;
  final $Res Function(CreateUploadRequest) _then;

/// Create a copy of CreateUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purpose = null,Object? contentType = freezed,}) {
  return _then(_self.copyWith(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as UploadPurpose,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateUploadRequest].
extension CreateUploadRequestPatterns on CreateUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UploadPurpose purpose,  String? contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUploadRequest() when $default != null:
return $default(_that.purpose,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UploadPurpose purpose,  String? contentType)  $default,) {final _that = this;
switch (_that) {
case _CreateUploadRequest():
return $default(_that.purpose,_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UploadPurpose purpose,  String? contentType)?  $default,) {final _that = this;
switch (_that) {
case _CreateUploadRequest() when $default != null:
return $default(_that.purpose,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateUploadRequest implements CreateUploadRequest {
  const _CreateUploadRequest({required this.purpose, this.contentType});
  factory _CreateUploadRequest.fromJson(Map<String, dynamic> json) => _$CreateUploadRequestFromJson(json);

@override final  UploadPurpose purpose;
@override final  String? contentType;

/// Create a copy of CreateUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUploadRequestCopyWith<_CreateUploadRequest> get copyWith => __$CreateUploadRequestCopyWithImpl<_CreateUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUploadRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,contentType);

@override
String toString() {
  return 'CreateUploadRequest(purpose: $purpose, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$CreateUploadRequestCopyWith<$Res> implements $CreateUploadRequestCopyWith<$Res> {
  factory _$CreateUploadRequestCopyWith(_CreateUploadRequest value, $Res Function(_CreateUploadRequest) _then) = __$CreateUploadRequestCopyWithImpl;
@override @useResult
$Res call({
 UploadPurpose purpose, String? contentType
});




}
/// @nodoc
class __$CreateUploadRequestCopyWithImpl<$Res>
    implements _$CreateUploadRequestCopyWith<$Res> {
  __$CreateUploadRequestCopyWithImpl(this._self, this._then);

  final _CreateUploadRequest _self;
  final $Res Function(_CreateUploadRequest) _then;

/// Create a copy of CreateUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purpose = null,Object? contentType = freezed,}) {
  return _then(_CreateUploadRequest(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as UploadPurpose,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
