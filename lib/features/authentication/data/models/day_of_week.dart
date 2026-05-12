import 'package:json_annotation/json_annotation.dart';

enum DayOfWeek {
  @JsonValue('MONDAY')
  monday('Lundi'),
  @JsonValue('TUESDAY')
  tuesday('Mardi'),
  @JsonValue('WEDNESDAY')
  wednesday('Mercredi'),
  @JsonValue('THURSDAY')
  thursday('Jeudi'),
  @JsonValue('FRIDAY')
  friday('Vendredi'),
  @JsonValue('SATURDAY')
  saturday('Samedi'),
  @JsonValue('SUNDAY')
  sunday('Dimanche');

  const DayOfWeek(this.label);

  final String label;
}
