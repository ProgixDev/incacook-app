import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/features/authentication/data/models/day_of_week.dart';

part 'opening_hours.freezed.dart';
part 'opening_hours.g.dart';

/// One opening-hours row per day, as sent / returned by §3.15.
///
/// On the request side [startTime]/[endTime] are `"HH:mm"` strings.
/// On the response side the backend currently echoes them as
/// `"1970-01-01T09:00:00.000Z"` ISO timestamps — we accept the string as-is
/// and let UI code parse if it needs a [TimeOfDay].
@freezed
abstract class OpeningHoursRow with _$OpeningHoursRow {
  const factory OpeningHoursRow({
    required DayOfWeek dayOfWeek,
    required String startTime,
    required String endTime,
  }) = _OpeningHoursRow;

  factory OpeningHoursRow.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursRowFromJson(json);
}
