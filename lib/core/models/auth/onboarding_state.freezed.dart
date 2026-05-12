// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingState {

 UserRole get role;/// First incomplete step in canonical role order, or null when
/// every step is `complete` or `skipped`. Wizard's cold-start resume
/// maps this to a [SignupStep] to jump the PageView.
 String? get next; Map<String, OnboardingStatus> get steps;/// KYC review state aggregated across the user's KycDocument rows.
/// Null for buyers (no KYC required).
 KycReviewState? get kycReviewState;/// Server-derived gate flags. Only one of the two is present per role.
 bool? get canList; bool? get canDeliver;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);

  /// Serializes this OnboardingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.role, role) || other.role == role)&&(identical(other.next, next) || other.next == next)&&const DeepCollectionEquality().equals(other.steps, steps)&&(identical(other.kycReviewState, kycReviewState) || other.kycReviewState == kycReviewState)&&(identical(other.canList, canList) || other.canList == canList)&&(identical(other.canDeliver, canDeliver) || other.canDeliver == canDeliver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,next,const DeepCollectionEquality().hash(steps),kycReviewState,canList,canDeliver);

@override
String toString() {
  return 'OnboardingState(role: $role, next: $next, steps: $steps, kycReviewState: $kycReviewState, canList: $canList, canDeliver: $canDeliver)';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 UserRole role, String? next, Map<String, OnboardingStatus> steps, KycReviewState? kycReviewState, bool? canList, bool? canDeliver
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? next = freezed,Object? steps = null,Object? kycReviewState = freezed,Object? canList = freezed,Object? canDeliver = freezed,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as Map<String, OnboardingStatus>,kycReviewState: freezed == kycReviewState ? _self.kycReviewState : kycReviewState // ignore: cast_nullable_to_non_nullable
as KycReviewState?,canList: freezed == canList ? _self.canList : canList // ignore: cast_nullable_to_non_nullable
as bool?,canDeliver: freezed == canDeliver ? _self.canDeliver : canDeliver // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserRole role,  String? next,  Map<String, OnboardingStatus> steps,  KycReviewState? kycReviewState,  bool? canList,  bool? canDeliver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.role,_that.next,_that.steps,_that.kycReviewState,_that.canList,_that.canDeliver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserRole role,  String? next,  Map<String, OnboardingStatus> steps,  KycReviewState? kycReviewState,  bool? canList,  bool? canDeliver)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.role,_that.next,_that.steps,_that.kycReviewState,_that.canList,_that.canDeliver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserRole role,  String? next,  Map<String, OnboardingStatus> steps,  KycReviewState? kycReviewState,  bool? canList,  bool? canDeliver)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.role,_that.next,_that.steps,_that.kycReviewState,_that.canList,_that.canDeliver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingState implements OnboardingState {
  const _OnboardingState({required this.role, this.next, final  Map<String, OnboardingStatus> steps = const <String, OnboardingStatus>{}, this.kycReviewState, this.canList, this.canDeliver}): _steps = steps;
  factory _OnboardingState.fromJson(Map<String, dynamic> json) => _$OnboardingStateFromJson(json);

@override final  UserRole role;
/// First incomplete step in canonical role order, or null when
/// every step is `complete` or `skipped`. Wizard's cold-start resume
/// maps this to a [SignupStep] to jump the PageView.
@override final  String? next;
 final  Map<String, OnboardingStatus> _steps;
@override@JsonKey() Map<String, OnboardingStatus> get steps {
  if (_steps is EqualUnmodifiableMapView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_steps);
}

/// KYC review state aggregated across the user's KycDocument rows.
/// Null for buyers (no KYC required).
@override final  KycReviewState? kycReviewState;
/// Server-derived gate flags. Only one of the two is present per role.
@override final  bool? canList;
@override final  bool? canDeliver;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.role, role) || other.role == role)&&(identical(other.next, next) || other.next == next)&&const DeepCollectionEquality().equals(other._steps, _steps)&&(identical(other.kycReviewState, kycReviewState) || other.kycReviewState == kycReviewState)&&(identical(other.canList, canList) || other.canList == canList)&&(identical(other.canDeliver, canDeliver) || other.canDeliver == canDeliver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,next,const DeepCollectionEquality().hash(_steps),kycReviewState,canList,canDeliver);

@override
String toString() {
  return 'OnboardingState(role: $role, next: $next, steps: $steps, kycReviewState: $kycReviewState, canList: $canList, canDeliver: $canDeliver)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 UserRole role, String? next, Map<String, OnboardingStatus> steps, KycReviewState? kycReviewState, bool? canList, bool? canDeliver
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? next = freezed,Object? steps = null,Object? kycReviewState = freezed,Object? canList = freezed,Object? canDeliver = freezed,}) {
  return _then(_OnboardingState(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as Map<String, OnboardingStatus>,kycReviewState: freezed == kycReviewState ? _self.kycReviewState : kycReviewState // ignore: cast_nullable_to_non_nullable
as KycReviewState?,canList: freezed == canList ? _self.canList : canList // ignore: cast_nullable_to_non_nullable
as bool?,canDeliver: freezed == canDeliver ? _self.canDeliver : canDeliver // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
