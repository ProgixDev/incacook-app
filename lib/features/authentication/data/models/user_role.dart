import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('BUYER')
  buyer,
  @JsonValue('SELLER')
  seller,
  @JsonValue('DRIVER')
  driver;

  /// Wire value the backend expects (mirrors the @JsonValue above).
  /// Useful for the few places we URL-encode the role rather than
  /// serialize it as part of a body.
  String get wire => switch (this) {
    UserRole.buyer => 'BUYER',
    UserRole.seller => 'SELLER',
    UserRole.driver => 'DRIVER',
  };

  static UserRole fromWire(String value) => switch (value) {
    'BUYER' => UserRole.buyer,
    'SELLER' => UserRole.seller,
    'DRIVER' => UserRole.driver,
    _ => throw ArgumentError.value(value, 'value', 'unknown UserRole'),
  };
}
