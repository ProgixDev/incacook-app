// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_extra.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingExtra {

 String get id; String get label; int get priceDeltaCents; bool get isSelectedByDefault; int get sortOrder;
/// Create a copy of ListingExtra
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingExtraCopyWith<ListingExtra> get copyWith => _$ListingExtraCopyWithImpl<ListingExtra>(this as ListingExtra, _$identity);

  /// Serializes this ListingExtra to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingExtra&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.priceDeltaCents, priceDeltaCents) || other.priceDeltaCents == priceDeltaCents)&&(identical(other.isSelectedByDefault, isSelectedByDefault) || other.isSelectedByDefault == isSelectedByDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,priceDeltaCents,isSelectedByDefault,sortOrder);

@override
String toString() {
  return 'ListingExtra(id: $id, label: $label, priceDeltaCents: $priceDeltaCents, isSelectedByDefault: $isSelectedByDefault, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $ListingExtraCopyWith<$Res>  {
  factory $ListingExtraCopyWith(ListingExtra value, $Res Function(ListingExtra) _then) = _$ListingExtraCopyWithImpl;
@useResult
$Res call({
 String id, String label, int priceDeltaCents, bool isSelectedByDefault, int sortOrder
});




}
/// @nodoc
class _$ListingExtraCopyWithImpl<$Res>
    implements $ListingExtraCopyWith<$Res> {
  _$ListingExtraCopyWithImpl(this._self, this._then);

  final ListingExtra _self;
  final $Res Function(ListingExtra) _then;

/// Create a copy of ListingExtra
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? priceDeltaCents = null,Object? isSelectedByDefault = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,priceDeltaCents: null == priceDeltaCents ? _self.priceDeltaCents : priceDeltaCents // ignore: cast_nullable_to_non_nullable
as int,isSelectedByDefault: null == isSelectedByDefault ? _self.isSelectedByDefault : isSelectedByDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingExtra].
extension ListingExtraPatterns on ListingExtra {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingExtra value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingExtra() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingExtra value)  $default,){
final _that = this;
switch (_that) {
case _ListingExtra():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingExtra value)?  $default,){
final _that = this;
switch (_that) {
case _ListingExtra() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  int priceDeltaCents,  bool isSelectedByDefault,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingExtra() when $default != null:
return $default(_that.id,_that.label,_that.priceDeltaCents,_that.isSelectedByDefault,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  int priceDeltaCents,  bool isSelectedByDefault,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _ListingExtra():
return $default(_that.id,_that.label,_that.priceDeltaCents,_that.isSelectedByDefault,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  int priceDeltaCents,  bool isSelectedByDefault,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _ListingExtra() when $default != null:
return $default(_that.id,_that.label,_that.priceDeltaCents,_that.isSelectedByDefault,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingExtra implements ListingExtra {
  const _ListingExtra({required this.id, required this.label, required this.priceDeltaCents, this.isSelectedByDefault = false, this.sortOrder = 0});
  factory _ListingExtra.fromJson(Map<String, dynamic> json) => _$ListingExtraFromJson(json);

@override final  String id;
@override final  String label;
@override final  int priceDeltaCents;
@override@JsonKey() final  bool isSelectedByDefault;
@override@JsonKey() final  int sortOrder;

/// Create a copy of ListingExtra
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingExtraCopyWith<_ListingExtra> get copyWith => __$ListingExtraCopyWithImpl<_ListingExtra>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingExtraToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingExtra&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.priceDeltaCents, priceDeltaCents) || other.priceDeltaCents == priceDeltaCents)&&(identical(other.isSelectedByDefault, isSelectedByDefault) || other.isSelectedByDefault == isSelectedByDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,priceDeltaCents,isSelectedByDefault,sortOrder);

@override
String toString() {
  return 'ListingExtra(id: $id, label: $label, priceDeltaCents: $priceDeltaCents, isSelectedByDefault: $isSelectedByDefault, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ListingExtraCopyWith<$Res> implements $ListingExtraCopyWith<$Res> {
  factory _$ListingExtraCopyWith(_ListingExtra value, $Res Function(_ListingExtra) _then) = __$ListingExtraCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, int priceDeltaCents, bool isSelectedByDefault, int sortOrder
});




}
/// @nodoc
class __$ListingExtraCopyWithImpl<$Res>
    implements _$ListingExtraCopyWith<$Res> {
  __$ListingExtraCopyWithImpl(this._self, this._then);

  final _ListingExtra _self;
  final $Res Function(_ListingExtra) _then;

/// Create a copy of ListingExtra
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? priceDeltaCents = null,Object? isSelectedByDefault = null,Object? sortOrder = null,}) {
  return _then(_ListingExtra(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,priceDeltaCents: null == priceDeltaCents ? _self.priceDeltaCents : priceDeltaCents // ignore: cast_nullable_to_non_nullable
as int,isSelectedByDefault: null == isSelectedByDefault ? _self.isSelectedByDefault : isSelectedByDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
