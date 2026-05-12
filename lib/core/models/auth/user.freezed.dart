// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get email; String? get phone; UserRole get role; String get firstName; String get lastName; String? get avatarPath; bool get emailVerified; bool get phoneVerified; String? get createdAt;@JsonKey(name: 'buyerProfile') BuyerAccount? get buyerAccount;@JsonKey(name: 'sellerProfile') SellerAccount? get sellerAccount;@JsonKey(name: 'driverProfile') DriverAccount? get driverAccount;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.avatarPath, avatarPath) || other.avatarPath == avatarPath)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.buyerAccount, buyerAccount) || other.buyerAccount == buyerAccount)&&(identical(other.sellerAccount, sellerAccount) || other.sellerAccount == sellerAccount)&&(identical(other.driverAccount, driverAccount) || other.driverAccount == driverAccount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,phone,role,firstName,lastName,avatarPath,emailVerified,phoneVerified,createdAt,buyerAccount,sellerAccount,driverAccount);

@override
String toString() {
  return 'User(id: $id, email: $email, phone: $phone, role: $role, firstName: $firstName, lastName: $lastName, avatarPath: $avatarPath, emailVerified: $emailVerified, phoneVerified: $phoneVerified, createdAt: $createdAt, buyerAccount: $buyerAccount, sellerAccount: $sellerAccount, driverAccount: $driverAccount)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? phone, UserRole role, String firstName, String lastName, String? avatarPath, bool emailVerified, bool phoneVerified, String? createdAt,@JsonKey(name: 'buyerProfile') BuyerAccount? buyerAccount,@JsonKey(name: 'sellerProfile') SellerAccount? sellerAccount,@JsonKey(name: 'driverProfile') DriverAccount? driverAccount
});


$BuyerAccountCopyWith<$Res>? get buyerAccount;$SellerAccountCopyWith<$Res>? get sellerAccount;$DriverAccountCopyWith<$Res>? get driverAccount;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? phone = freezed,Object? role = null,Object? firstName = null,Object? lastName = null,Object? avatarPath = freezed,Object? emailVerified = null,Object? phoneVerified = null,Object? createdAt = freezed,Object? buyerAccount = freezed,Object? sellerAccount = freezed,Object? driverAccount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,avatarPath: freezed == avatarPath ? _self.avatarPath : avatarPath // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,buyerAccount: freezed == buyerAccount ? _self.buyerAccount : buyerAccount // ignore: cast_nullable_to_non_nullable
as BuyerAccount?,sellerAccount: freezed == sellerAccount ? _self.sellerAccount : sellerAccount // ignore: cast_nullable_to_non_nullable
as SellerAccount?,driverAccount: freezed == driverAccount ? _self.driverAccount : driverAccount // ignore: cast_nullable_to_non_nullable
as DriverAccount?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuyerAccountCopyWith<$Res>? get buyerAccount {
    if (_self.buyerAccount == null) {
    return null;
  }

  return $BuyerAccountCopyWith<$Res>(_self.buyerAccount!, (value) {
    return _then(_self.copyWith(buyerAccount: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SellerAccountCopyWith<$Res>? get sellerAccount {
    if (_self.sellerAccount == null) {
    return null;
  }

  return $SellerAccountCopyWith<$Res>(_self.sellerAccount!, (value) {
    return _then(_self.copyWith(sellerAccount: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverAccountCopyWith<$Res>? get driverAccount {
    if (_self.driverAccount == null) {
    return null;
  }

  return $DriverAccountCopyWith<$Res>(_self.driverAccount!, (value) {
    return _then(_self.copyWith(driverAccount: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String? phone,  UserRole role,  String firstName,  String lastName,  String? avatarPath,  bool emailVerified,  bool phoneVerified,  String? createdAt, @JsonKey(name: 'buyerProfile')  BuyerAccount? buyerAccount, @JsonKey(name: 'sellerProfile')  SellerAccount? sellerAccount, @JsonKey(name: 'driverProfile')  DriverAccount? driverAccount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.phone,_that.role,_that.firstName,_that.lastName,_that.avatarPath,_that.emailVerified,_that.phoneVerified,_that.createdAt,_that.buyerAccount,_that.sellerAccount,_that.driverAccount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String? phone,  UserRole role,  String firstName,  String lastName,  String? avatarPath,  bool emailVerified,  bool phoneVerified,  String? createdAt, @JsonKey(name: 'buyerProfile')  BuyerAccount? buyerAccount, @JsonKey(name: 'sellerProfile')  SellerAccount? sellerAccount, @JsonKey(name: 'driverProfile')  DriverAccount? driverAccount)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.phone,_that.role,_that.firstName,_that.lastName,_that.avatarPath,_that.emailVerified,_that.phoneVerified,_that.createdAt,_that.buyerAccount,_that.sellerAccount,_that.driverAccount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String? phone,  UserRole role,  String firstName,  String lastName,  String? avatarPath,  bool emailVerified,  bool phoneVerified,  String? createdAt, @JsonKey(name: 'buyerProfile')  BuyerAccount? buyerAccount, @JsonKey(name: 'sellerProfile')  SellerAccount? sellerAccount, @JsonKey(name: 'driverProfile')  DriverAccount? driverAccount)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.phone,_that.role,_that.firstName,_that.lastName,_that.avatarPath,_that.emailVerified,_that.phoneVerified,_that.createdAt,_that.buyerAccount,_that.sellerAccount,_that.driverAccount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.email, this.phone, required this.role, required this.firstName, required this.lastName, this.avatarPath, this.emailVerified = false, this.phoneVerified = false, this.createdAt, @JsonKey(name: 'buyerProfile') this.buyerAccount, @JsonKey(name: 'sellerProfile') this.sellerAccount, @JsonKey(name: 'driverProfile') this.driverAccount});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String? phone;
@override final  UserRole role;
@override final  String firstName;
@override final  String lastName;
@override final  String? avatarPath;
@override@JsonKey() final  bool emailVerified;
@override@JsonKey() final  bool phoneVerified;
@override final  String? createdAt;
@override@JsonKey(name: 'buyerProfile') final  BuyerAccount? buyerAccount;
@override@JsonKey(name: 'sellerProfile') final  SellerAccount? sellerAccount;
@override@JsonKey(name: 'driverProfile') final  DriverAccount? driverAccount;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.avatarPath, avatarPath) || other.avatarPath == avatarPath)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.buyerAccount, buyerAccount) || other.buyerAccount == buyerAccount)&&(identical(other.sellerAccount, sellerAccount) || other.sellerAccount == sellerAccount)&&(identical(other.driverAccount, driverAccount) || other.driverAccount == driverAccount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,phone,role,firstName,lastName,avatarPath,emailVerified,phoneVerified,createdAt,buyerAccount,sellerAccount,driverAccount);

@override
String toString() {
  return 'User(id: $id, email: $email, phone: $phone, role: $role, firstName: $firstName, lastName: $lastName, avatarPath: $avatarPath, emailVerified: $emailVerified, phoneVerified: $phoneVerified, createdAt: $createdAt, buyerAccount: $buyerAccount, sellerAccount: $sellerAccount, driverAccount: $driverAccount)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? phone, UserRole role, String firstName, String lastName, String? avatarPath, bool emailVerified, bool phoneVerified, String? createdAt,@JsonKey(name: 'buyerProfile') BuyerAccount? buyerAccount,@JsonKey(name: 'sellerProfile') SellerAccount? sellerAccount,@JsonKey(name: 'driverProfile') DriverAccount? driverAccount
});


@override $BuyerAccountCopyWith<$Res>? get buyerAccount;@override $SellerAccountCopyWith<$Res>? get sellerAccount;@override $DriverAccountCopyWith<$Res>? get driverAccount;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? phone = freezed,Object? role = null,Object? firstName = null,Object? lastName = null,Object? avatarPath = freezed,Object? emailVerified = null,Object? phoneVerified = null,Object? createdAt = freezed,Object? buyerAccount = freezed,Object? sellerAccount = freezed,Object? driverAccount = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,avatarPath: freezed == avatarPath ? _self.avatarPath : avatarPath // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,buyerAccount: freezed == buyerAccount ? _self.buyerAccount : buyerAccount // ignore: cast_nullable_to_non_nullable
as BuyerAccount?,sellerAccount: freezed == sellerAccount ? _self.sellerAccount : sellerAccount // ignore: cast_nullable_to_non_nullable
as SellerAccount?,driverAccount: freezed == driverAccount ? _self.driverAccount : driverAccount // ignore: cast_nullable_to_non_nullable
as DriverAccount?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuyerAccountCopyWith<$Res>? get buyerAccount {
    if (_self.buyerAccount == null) {
    return null;
  }

  return $BuyerAccountCopyWith<$Res>(_self.buyerAccount!, (value) {
    return _then(_self.copyWith(buyerAccount: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SellerAccountCopyWith<$Res>? get sellerAccount {
    if (_self.sellerAccount == null) {
    return null;
  }

  return $SellerAccountCopyWith<$Res>(_self.sellerAccount!, (value) {
    return _then(_self.copyWith(sellerAccount: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverAccountCopyWith<$Res>? get driverAccount {
    if (_self.driverAccount == null) {
    return null;
  }

  return $DriverAccountCopyWith<$Res>(_self.driverAccount!, (value) {
    return _then(_self.copyWith(driverAccount: value));
  });
}
}

// dart format on
