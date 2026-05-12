// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accept_charter_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcceptCharterRequest {

 Charter get charter; String get version;
/// Create a copy of AcceptCharterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptCharterRequestCopyWith<AcceptCharterRequest> get copyWith => _$AcceptCharterRequestCopyWithImpl<AcceptCharterRequest>(this as AcceptCharterRequest, _$identity);

  /// Serializes this AcceptCharterRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptCharterRequest&&(identical(other.charter, charter) || other.charter == charter)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charter,version);

@override
String toString() {
  return 'AcceptCharterRequest(charter: $charter, version: $version)';
}


}

/// @nodoc
abstract mixin class $AcceptCharterRequestCopyWith<$Res>  {
  factory $AcceptCharterRequestCopyWith(AcceptCharterRequest value, $Res Function(AcceptCharterRequest) _then) = _$AcceptCharterRequestCopyWithImpl;
@useResult
$Res call({
 Charter charter, String version
});




}
/// @nodoc
class _$AcceptCharterRequestCopyWithImpl<$Res>
    implements $AcceptCharterRequestCopyWith<$Res> {
  _$AcceptCharterRequestCopyWithImpl(this._self, this._then);

  final AcceptCharterRequest _self;
  final $Res Function(AcceptCharterRequest) _then;

/// Create a copy of AcceptCharterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? charter = null,Object? version = null,}) {
  return _then(_self.copyWith(
charter: null == charter ? _self.charter : charter // ignore: cast_nullable_to_non_nullable
as Charter,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AcceptCharterRequest].
extension AcceptCharterRequestPatterns on AcceptCharterRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptCharterRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptCharterRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptCharterRequest value)  $default,){
final _that = this;
switch (_that) {
case _AcceptCharterRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptCharterRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptCharterRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Charter charter,  String version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptCharterRequest() when $default != null:
return $default(_that.charter,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Charter charter,  String version)  $default,) {final _that = this;
switch (_that) {
case _AcceptCharterRequest():
return $default(_that.charter,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Charter charter,  String version)?  $default,) {final _that = this;
switch (_that) {
case _AcceptCharterRequest() when $default != null:
return $default(_that.charter,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcceptCharterRequest implements AcceptCharterRequest {
  const _AcceptCharterRequest({required this.charter, required this.version});
  factory _AcceptCharterRequest.fromJson(Map<String, dynamic> json) => _$AcceptCharterRequestFromJson(json);

@override final  Charter charter;
@override final  String version;

/// Create a copy of AcceptCharterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptCharterRequestCopyWith<_AcceptCharterRequest> get copyWith => __$AcceptCharterRequestCopyWithImpl<_AcceptCharterRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptCharterRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptCharterRequest&&(identical(other.charter, charter) || other.charter == charter)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charter,version);

@override
String toString() {
  return 'AcceptCharterRequest(charter: $charter, version: $version)';
}


}

/// @nodoc
abstract mixin class _$AcceptCharterRequestCopyWith<$Res> implements $AcceptCharterRequestCopyWith<$Res> {
  factory _$AcceptCharterRequestCopyWith(_AcceptCharterRequest value, $Res Function(_AcceptCharterRequest) _then) = __$AcceptCharterRequestCopyWithImpl;
@override @useResult
$Res call({
 Charter charter, String version
});




}
/// @nodoc
class __$AcceptCharterRequestCopyWithImpl<$Res>
    implements _$AcceptCharterRequestCopyWith<$Res> {
  __$AcceptCharterRequestCopyWithImpl(this._self, this._then);

  final _AcceptCharterRequest _self;
  final $Res Function(_AcceptCharterRequest) _then;

/// Create a copy of AcceptCharterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? charter = null,Object? version = null,}) {
  return _then(_AcceptCharterRequest(
charter: null == charter ? _self.charter : charter // ignore: cast_nullable_to_non_nullable
as Charter,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
