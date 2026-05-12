// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'charter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CharterAcceptance {

 Charter get charter; String get version; String get acceptedAt;
/// Create a copy of CharterAcceptance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharterAcceptanceCopyWith<CharterAcceptance> get copyWith => _$CharterAcceptanceCopyWithImpl<CharterAcceptance>(this as CharterAcceptance, _$identity);

  /// Serializes this CharterAcceptance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharterAcceptance&&(identical(other.charter, charter) || other.charter == charter)&&(identical(other.version, version) || other.version == version)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charter,version,acceptedAt);

@override
String toString() {
  return 'CharterAcceptance(charter: $charter, version: $version, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class $CharterAcceptanceCopyWith<$Res>  {
  factory $CharterAcceptanceCopyWith(CharterAcceptance value, $Res Function(CharterAcceptance) _then) = _$CharterAcceptanceCopyWithImpl;
@useResult
$Res call({
 Charter charter, String version, String acceptedAt
});




}
/// @nodoc
class _$CharterAcceptanceCopyWithImpl<$Res>
    implements $CharterAcceptanceCopyWith<$Res> {
  _$CharterAcceptanceCopyWithImpl(this._self, this._then);

  final CharterAcceptance _self;
  final $Res Function(CharterAcceptance) _then;

/// Create a copy of CharterAcceptance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? charter = null,Object? version = null,Object? acceptedAt = null,}) {
  return _then(_self.copyWith(
charter: null == charter ? _self.charter : charter // ignore: cast_nullable_to_non_nullable
as Charter,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CharterAcceptance].
extension CharterAcceptancePatterns on CharterAcceptance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CharterAcceptance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CharterAcceptance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CharterAcceptance value)  $default,){
final _that = this;
switch (_that) {
case _CharterAcceptance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CharterAcceptance value)?  $default,){
final _that = this;
switch (_that) {
case _CharterAcceptance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Charter charter,  String version,  String acceptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CharterAcceptance() when $default != null:
return $default(_that.charter,_that.version,_that.acceptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Charter charter,  String version,  String acceptedAt)  $default,) {final _that = this;
switch (_that) {
case _CharterAcceptance():
return $default(_that.charter,_that.version,_that.acceptedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Charter charter,  String version,  String acceptedAt)?  $default,) {final _that = this;
switch (_that) {
case _CharterAcceptance() when $default != null:
return $default(_that.charter,_that.version,_that.acceptedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CharterAcceptance implements CharterAcceptance {
  const _CharterAcceptance({required this.charter, required this.version, required this.acceptedAt});
  factory _CharterAcceptance.fromJson(Map<String, dynamic> json) => _$CharterAcceptanceFromJson(json);

@override final  Charter charter;
@override final  String version;
@override final  String acceptedAt;

/// Create a copy of CharterAcceptance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharterAcceptanceCopyWith<_CharterAcceptance> get copyWith => __$CharterAcceptanceCopyWithImpl<_CharterAcceptance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharterAcceptanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CharterAcceptance&&(identical(other.charter, charter) || other.charter == charter)&&(identical(other.version, version) || other.version == version)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charter,version,acceptedAt);

@override
String toString() {
  return 'CharterAcceptance(charter: $charter, version: $version, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class _$CharterAcceptanceCopyWith<$Res> implements $CharterAcceptanceCopyWith<$Res> {
  factory _$CharterAcceptanceCopyWith(_CharterAcceptance value, $Res Function(_CharterAcceptance) _then) = __$CharterAcceptanceCopyWithImpl;
@override @useResult
$Res call({
 Charter charter, String version, String acceptedAt
});




}
/// @nodoc
class __$CharterAcceptanceCopyWithImpl<$Res>
    implements _$CharterAcceptanceCopyWith<$Res> {
  __$CharterAcceptanceCopyWithImpl(this._self, this._then);

  final _CharterAcceptance _self;
  final $Res Function(_CharterAcceptance) _then;

/// Create a copy of CharterAcceptance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? charter = null,Object? version = null,Object? acceptedAt = null,}) {
  return _then(_CharterAcceptance(
charter: null == charter ? _self.charter : charter // ignore: cast_nullable_to_non_nullable
as Charter,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
