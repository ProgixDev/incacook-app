// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_profile_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompleteProfileRequest {

 String get firstName; String get lastName; UserRole get role; bool get acceptedCgu; bool get acceptedCgv;
/// Create a copy of CompleteProfileRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompleteProfileRequestCopyWith<CompleteProfileRequest> get copyWith => _$CompleteProfileRequestCopyWithImpl<CompleteProfileRequest>(this as CompleteProfileRequest, _$identity);

  /// Serializes this CompleteProfileRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompleteProfileRequest&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.acceptedCgu, acceptedCgu) || other.acceptedCgu == acceptedCgu)&&(identical(other.acceptedCgv, acceptedCgv) || other.acceptedCgv == acceptedCgv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,role,acceptedCgu,acceptedCgv);

@override
String toString() {
  return 'CompleteProfileRequest(firstName: $firstName, lastName: $lastName, role: $role, acceptedCgu: $acceptedCgu, acceptedCgv: $acceptedCgv)';
}


}

/// @nodoc
abstract mixin class $CompleteProfileRequestCopyWith<$Res>  {
  factory $CompleteProfileRequestCopyWith(CompleteProfileRequest value, $Res Function(CompleteProfileRequest) _then) = _$CompleteProfileRequestCopyWithImpl;
@useResult
$Res call({
 String firstName, String lastName, UserRole role, bool acceptedCgu, bool acceptedCgv
});




}
/// @nodoc
class _$CompleteProfileRequestCopyWithImpl<$Res>
    implements $CompleteProfileRequestCopyWith<$Res> {
  _$CompleteProfileRequestCopyWithImpl(this._self, this._then);

  final CompleteProfileRequest _self;
  final $Res Function(CompleteProfileRequest) _then;

/// Create a copy of CompleteProfileRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = null,Object? role = null,Object? acceptedCgu = null,Object? acceptedCgv = null,}) {
  return _then(_self.copyWith(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,acceptedCgu: null == acceptedCgu ? _self.acceptedCgu : acceptedCgu // ignore: cast_nullable_to_non_nullable
as bool,acceptedCgv: null == acceptedCgv ? _self.acceptedCgv : acceptedCgv // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CompleteProfileRequest].
extension CompleteProfileRequestPatterns on CompleteProfileRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompleteProfileRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompleteProfileRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompleteProfileRequest value)  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompleteProfileRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String lastName,  UserRole role,  bool acceptedCgu,  bool acceptedCgv)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompleteProfileRequest() when $default != null:
return $default(_that.firstName,_that.lastName,_that.role,_that.acceptedCgu,_that.acceptedCgv);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String lastName,  UserRole role,  bool acceptedCgu,  bool acceptedCgv)  $default,) {final _that = this;
switch (_that) {
case _CompleteProfileRequest():
return $default(_that.firstName,_that.lastName,_that.role,_that.acceptedCgu,_that.acceptedCgv);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String lastName,  UserRole role,  bool acceptedCgu,  bool acceptedCgv)?  $default,) {final _that = this;
switch (_that) {
case _CompleteProfileRequest() when $default != null:
return $default(_that.firstName,_that.lastName,_that.role,_that.acceptedCgu,_that.acceptedCgv);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompleteProfileRequest implements CompleteProfileRequest {
  const _CompleteProfileRequest({required this.firstName, required this.lastName, required this.role, required this.acceptedCgu, required this.acceptedCgv});
  factory _CompleteProfileRequest.fromJson(Map<String, dynamic> json) => _$CompleteProfileRequestFromJson(json);

@override final  String firstName;
@override final  String lastName;
@override final  UserRole role;
@override final  bool acceptedCgu;
@override final  bool acceptedCgv;

/// Create a copy of CompleteProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompleteProfileRequestCopyWith<_CompleteProfileRequest> get copyWith => __$CompleteProfileRequestCopyWithImpl<_CompleteProfileRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompleteProfileRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompleteProfileRequest&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.acceptedCgu, acceptedCgu) || other.acceptedCgu == acceptedCgu)&&(identical(other.acceptedCgv, acceptedCgv) || other.acceptedCgv == acceptedCgv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,role,acceptedCgu,acceptedCgv);

@override
String toString() {
  return 'CompleteProfileRequest(firstName: $firstName, lastName: $lastName, role: $role, acceptedCgu: $acceptedCgu, acceptedCgv: $acceptedCgv)';
}


}

/// @nodoc
abstract mixin class _$CompleteProfileRequestCopyWith<$Res> implements $CompleteProfileRequestCopyWith<$Res> {
  factory _$CompleteProfileRequestCopyWith(_CompleteProfileRequest value, $Res Function(_CompleteProfileRequest) _then) = __$CompleteProfileRequestCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String lastName, UserRole role, bool acceptedCgu, bool acceptedCgv
});




}
/// @nodoc
class __$CompleteProfileRequestCopyWithImpl<$Res>
    implements _$CompleteProfileRequestCopyWith<$Res> {
  __$CompleteProfileRequestCopyWithImpl(this._self, this._then);

  final _CompleteProfileRequest _self;
  final $Res Function(_CompleteProfileRequest) _then;

/// Create a copy of CompleteProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? role = null,Object? acceptedCgu = null,Object? acceptedCgv = null,}) {
  return _then(_CompleteProfileRequest(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,acceptedCgu: null == acceptedCgu ? _self.acceptedCgu : acceptedCgu // ignore: cast_nullable_to_non_nullable
as bool,acceptedCgv: null == acceptedCgv ? _self.acceptedCgv : acceptedCgv // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
