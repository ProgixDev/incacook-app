import 'package:json_annotation/json_annotation.dart';

enum Fulfillment {
  @JsonValue('DELIVERY')
  delivery,
  @JsonValue('PICKUP')
  pickup,
  @JsonValue('BOTH')
  both,
}
