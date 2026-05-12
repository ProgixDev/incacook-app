// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opening_hours.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OpeningHoursRow {

 DayOfWeek get dayOfWeek; String get startTime; String get endTime;
/// Create a copy of OpeningHoursRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpeningHoursRowCopyWith<OpeningHoursRow> get copyWith => _$OpeningHoursRowCopyWithImpl<OpeningHoursRow>(this as OpeningHoursRow, _$identity);

  /// Serializes this OpeningHoursRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpeningHoursRow&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'OpeningHoursRow(dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $OpeningHoursRowCopyWith<$Res>  {
  factory $OpeningHoursRowCopyWith(OpeningHoursRow value, $Res Function(OpeningHoursRow) _then) = _$OpeningHoursRowCopyWithImpl;
@useResult
$Res call({
 DayOfWeek dayOfWeek, String startTime, String endTime
});




}
/// @nodoc
class _$OpeningHoursRowCopyWithImpl<$Res>
    implements $OpeningHoursRowCopyWith<$Res> {
  _$OpeningHoursRowCopyWithImpl(this._self, this._then);

  final OpeningHoursRow _self;
  final $Res Function(OpeningHoursRow) _then;

/// Create a copy of OpeningHoursRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as DayOfWeek,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OpeningHoursRow].
extension OpeningHoursRowPatterns on OpeningHoursRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpeningHoursRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpeningHoursRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpeningHoursRow value)  $default,){
final _that = this;
switch (_that) {
case _OpeningHoursRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpeningHoursRow value)?  $default,){
final _that = this;
switch (_that) {
case _OpeningHoursRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DayOfWeek dayOfWeek,  String startTime,  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpeningHoursRow() when $default != null:
return $default(_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DayOfWeek dayOfWeek,  String startTime,  String endTime)  $default,) {final _that = this;
switch (_that) {
case _OpeningHoursRow():
return $default(_that.dayOfWeek,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DayOfWeek dayOfWeek,  String startTime,  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _OpeningHoursRow() when $default != null:
return $default(_that.dayOfWeek,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpeningHoursRow implements OpeningHoursRow {
  const _OpeningHoursRow({required this.dayOfWeek, required this.startTime, required this.endTime});
  factory _OpeningHoursRow.fromJson(Map<String, dynamic> json) => _$OpeningHoursRowFromJson(json);

@override final  DayOfWeek dayOfWeek;
@override final  String startTime;
@override final  String endTime;

/// Create a copy of OpeningHoursRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpeningHoursRowCopyWith<_OpeningHoursRow> get copyWith => __$OpeningHoursRowCopyWithImpl<_OpeningHoursRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpeningHoursRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpeningHoursRow&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,startTime,endTime);

@override
String toString() {
  return 'OpeningHoursRow(dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$OpeningHoursRowCopyWith<$Res> implements $OpeningHoursRowCopyWith<$Res> {
  factory _$OpeningHoursRowCopyWith(_OpeningHoursRow value, $Res Function(_OpeningHoursRow) _then) = __$OpeningHoursRowCopyWithImpl;
@override @useResult
$Res call({
 DayOfWeek dayOfWeek, String startTime, String endTime
});




}
/// @nodoc
class __$OpeningHoursRowCopyWithImpl<$Res>
    implements _$OpeningHoursRowCopyWith<$Res> {
  __$OpeningHoursRowCopyWithImpl(this._self, this._then);

  final _OpeningHoursRow _self;
  final $Res Function(_OpeningHoursRow) _then;

/// Create a copy of OpeningHoursRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_OpeningHoursRow(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as DayOfWeek,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
