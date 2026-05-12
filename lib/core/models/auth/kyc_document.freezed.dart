// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycDocument {

 String get id; KycDocumentType get type; String get fileUrl; KycReviewState get reviewState; String? get rejectionReason; String get submittedAt; String? get reviewedAt; KycDocumentMetadata? get metadata;
/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycDocumentCopyWith<KycDocument> get copyWith => _$KycDocumentCopyWithImpl<KycDocument>(this as KycDocument, _$identity);

  /// Serializes this KycDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.reviewState, reviewState) || other.reviewState == reviewState)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fileUrl,reviewState,rejectionReason,submittedAt,reviewedAt,metadata);

@override
String toString() {
  return 'KycDocument(id: $id, type: $type, fileUrl: $fileUrl, reviewState: $reviewState, rejectionReason: $rejectionReason, submittedAt: $submittedAt, reviewedAt: $reviewedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $KycDocumentCopyWith<$Res>  {
  factory $KycDocumentCopyWith(KycDocument value, $Res Function(KycDocument) _then) = _$KycDocumentCopyWithImpl;
@useResult
$Res call({
 String id, KycDocumentType type, String fileUrl, KycReviewState reviewState, String? rejectionReason, String submittedAt, String? reviewedAt, KycDocumentMetadata? metadata
});


$KycDocumentMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$KycDocumentCopyWithImpl<$Res>
    implements $KycDocumentCopyWith<$Res> {
  _$KycDocumentCopyWithImpl(this._self, this._then);

  final KycDocument _self;
  final $Res Function(KycDocument) _then;

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? fileUrl = null,Object? reviewState = null,Object? rejectionReason = freezed,Object? submittedAt = null,Object? reviewedAt = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KycDocumentType,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,reviewState: null == reviewState ? _self.reviewState : reviewState // ignore: cast_nullable_to_non_nullable
as KycReviewState,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as KycDocumentMetadata?,
  ));
}
/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KycDocumentMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $KycDocumentMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [KycDocument].
extension KycDocumentPatterns on KycDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycDocument value)  $default,){
final _that = this;
switch (_that) {
case _KycDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycDocument value)?  $default,){
final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  KycDocumentType type,  String fileUrl,  KycReviewState reviewState,  String? rejectionReason,  String submittedAt,  String? reviewedAt,  KycDocumentMetadata? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
return $default(_that.id,_that.type,_that.fileUrl,_that.reviewState,_that.rejectionReason,_that.submittedAt,_that.reviewedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  KycDocumentType type,  String fileUrl,  KycReviewState reviewState,  String? rejectionReason,  String submittedAt,  String? reviewedAt,  KycDocumentMetadata? metadata)  $default,) {final _that = this;
switch (_that) {
case _KycDocument():
return $default(_that.id,_that.type,_that.fileUrl,_that.reviewState,_that.rejectionReason,_that.submittedAt,_that.reviewedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  KycDocumentType type,  String fileUrl,  KycReviewState reviewState,  String? rejectionReason,  String submittedAt,  String? reviewedAt,  KycDocumentMetadata? metadata)?  $default,) {final _that = this;
switch (_that) {
case _KycDocument() when $default != null:
return $default(_that.id,_that.type,_that.fileUrl,_that.reviewState,_that.rejectionReason,_that.submittedAt,_that.reviewedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycDocument implements KycDocument {
  const _KycDocument({required this.id, required this.type, required this.fileUrl, required this.reviewState, this.rejectionReason, required this.submittedAt, this.reviewedAt, this.metadata});
  factory _KycDocument.fromJson(Map<String, dynamic> json) => _$KycDocumentFromJson(json);

@override final  String id;
@override final  KycDocumentType type;
@override final  String fileUrl;
@override final  KycReviewState reviewState;
@override final  String? rejectionReason;
@override final  String submittedAt;
@override final  String? reviewedAt;
@override final  KycDocumentMetadata? metadata;

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycDocumentCopyWith<_KycDocument> get copyWith => __$KycDocumentCopyWithImpl<_KycDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.reviewState, reviewState) || other.reviewState == reviewState)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fileUrl,reviewState,rejectionReason,submittedAt,reviewedAt,metadata);

@override
String toString() {
  return 'KycDocument(id: $id, type: $type, fileUrl: $fileUrl, reviewState: $reviewState, rejectionReason: $rejectionReason, submittedAt: $submittedAt, reviewedAt: $reviewedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$KycDocumentCopyWith<$Res> implements $KycDocumentCopyWith<$Res> {
  factory _$KycDocumentCopyWith(_KycDocument value, $Res Function(_KycDocument) _then) = __$KycDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, KycDocumentType type, String fileUrl, KycReviewState reviewState, String? rejectionReason, String submittedAt, String? reviewedAt, KycDocumentMetadata? metadata
});


@override $KycDocumentMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$KycDocumentCopyWithImpl<$Res>
    implements _$KycDocumentCopyWith<$Res> {
  __$KycDocumentCopyWithImpl(this._self, this._then);

  final _KycDocument _self;
  final $Res Function(_KycDocument) _then;

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? fileUrl = null,Object? reviewState = null,Object? rejectionReason = freezed,Object? submittedAt = null,Object? reviewedAt = freezed,Object? metadata = freezed,}) {
  return _then(_KycDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KycDocumentType,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,reviewState: null == reviewState ? _self.reviewState : reviewState // ignore: cast_nullable_to_non_nullable
as KycReviewState,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as KycDocumentMetadata?,
  ));
}

/// Create a copy of KycDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KycDocumentMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $KycDocumentMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$KycDocumentMetadata {

 IdDocumentType? get idDocumentType;
/// Create a copy of KycDocumentMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycDocumentMetadataCopyWith<KycDocumentMetadata> get copyWith => _$KycDocumentMetadataCopyWithImpl<KycDocumentMetadata>(this as KycDocumentMetadata, _$identity);

  /// Serializes this KycDocumentMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycDocumentMetadata&&(identical(other.idDocumentType, idDocumentType) || other.idDocumentType == idDocumentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idDocumentType);

@override
String toString() {
  return 'KycDocumentMetadata(idDocumentType: $idDocumentType)';
}


}

/// @nodoc
abstract mixin class $KycDocumentMetadataCopyWith<$Res>  {
  factory $KycDocumentMetadataCopyWith(KycDocumentMetadata value, $Res Function(KycDocumentMetadata) _then) = _$KycDocumentMetadataCopyWithImpl;
@useResult
$Res call({
 IdDocumentType? idDocumentType
});




}
/// @nodoc
class _$KycDocumentMetadataCopyWithImpl<$Res>
    implements $KycDocumentMetadataCopyWith<$Res> {
  _$KycDocumentMetadataCopyWithImpl(this._self, this._then);

  final KycDocumentMetadata _self;
  final $Res Function(KycDocumentMetadata) _then;

/// Create a copy of KycDocumentMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idDocumentType = freezed,}) {
  return _then(_self.copyWith(
idDocumentType: freezed == idDocumentType ? _self.idDocumentType : idDocumentType // ignore: cast_nullable_to_non_nullable
as IdDocumentType?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycDocumentMetadata].
extension KycDocumentMetadataPatterns on KycDocumentMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycDocumentMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycDocumentMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycDocumentMetadata value)  $default,){
final _that = this;
switch (_that) {
case _KycDocumentMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycDocumentMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _KycDocumentMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdDocumentType? idDocumentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycDocumentMetadata() when $default != null:
return $default(_that.idDocumentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdDocumentType? idDocumentType)  $default,) {final _that = this;
switch (_that) {
case _KycDocumentMetadata():
return $default(_that.idDocumentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdDocumentType? idDocumentType)?  $default,) {final _that = this;
switch (_that) {
case _KycDocumentMetadata() when $default != null:
return $default(_that.idDocumentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycDocumentMetadata implements KycDocumentMetadata {
  const _KycDocumentMetadata({this.idDocumentType});
  factory _KycDocumentMetadata.fromJson(Map<String, dynamic> json) => _$KycDocumentMetadataFromJson(json);

@override final  IdDocumentType? idDocumentType;

/// Create a copy of KycDocumentMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycDocumentMetadataCopyWith<_KycDocumentMetadata> get copyWith => __$KycDocumentMetadataCopyWithImpl<_KycDocumentMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycDocumentMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycDocumentMetadata&&(identical(other.idDocumentType, idDocumentType) || other.idDocumentType == idDocumentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idDocumentType);

@override
String toString() {
  return 'KycDocumentMetadata(idDocumentType: $idDocumentType)';
}


}

/// @nodoc
abstract mixin class _$KycDocumentMetadataCopyWith<$Res> implements $KycDocumentMetadataCopyWith<$Res> {
  factory _$KycDocumentMetadataCopyWith(_KycDocumentMetadata value, $Res Function(_KycDocumentMetadata) _then) = __$KycDocumentMetadataCopyWithImpl;
@override @useResult
$Res call({
 IdDocumentType? idDocumentType
});




}
/// @nodoc
class __$KycDocumentMetadataCopyWithImpl<$Res>
    implements _$KycDocumentMetadataCopyWith<$Res> {
  __$KycDocumentMetadataCopyWithImpl(this._self, this._then);

  final _KycDocumentMetadata _self;
  final $Res Function(_KycDocumentMetadata) _then;

/// Create a copy of KycDocumentMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idDocumentType = freezed,}) {
  return _then(_KycDocumentMetadata(
idDocumentType: freezed == idDocumentType ? _self.idDocumentType : idDocumentType // ignore: cast_nullable_to_non_nullable
as IdDocumentType?,
  ));
}


}

// dart format on
