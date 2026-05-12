// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  avatarPath: json['avatar_path'] as String?,
  emailVerified: json['email_verified'] as bool? ?? false,
  phoneVerified: json['phone_verified'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  buyerAccount: json['buyerProfile'] == null
      ? null
      : BuyerAccount.fromJson(json['buyerProfile'] as Map<String, dynamic>),
  sellerAccount: json['sellerProfile'] == null
      ? null
      : SellerAccount.fromJson(json['sellerProfile'] as Map<String, dynamic>),
  driverAccount: json['driverProfile'] == null
      ? null
      : DriverAccount.fromJson(json['driverProfile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone': ?instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'avatar_path': ?instance.avatarPath,
  'email_verified': instance.emailVerified,
  'phone_verified': instance.phoneVerified,
  'created_at': ?instance.createdAt,
  'buyerProfile': ?instance.buyerAccount?.toJson(),
  'sellerProfile': ?instance.sellerAccount?.toJson(),
  'driverProfile': ?instance.driverAccount?.toJson(),
};

const _$UserRoleEnumMap = {
  UserRole.buyer: 'BUYER',
  UserRole.seller: 'SELLER',
  UserRole.driver: 'DRIVER',
};
