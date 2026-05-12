// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OpeningHoursRow _$OpeningHoursRowFromJson(Map<String, dynamic> json) =>
    _OpeningHoursRow(
      dayOfWeek: $enumDecode(_$DayOfWeekEnumMap, json['day_of_week']),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );

Map<String, dynamic> _$OpeningHoursRowToJson(_OpeningHoursRow instance) =>
    <String, dynamic>{
      'day_of_week': _$DayOfWeekEnumMap[instance.dayOfWeek]!,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };

const _$DayOfWeekEnumMap = {
  DayOfWeek.monday: 'MONDAY',
  DayOfWeek.tuesday: 'TUESDAY',
  DayOfWeek.wednesday: 'WEDNESDAY',
  DayOfWeek.thursday: 'THURSDAY',
  DayOfWeek.friday: 'FRIDAY',
  DayOfWeek.saturday: 'SATURDAY',
  DayOfWeek.sunday: 'SUNDAY',
};
