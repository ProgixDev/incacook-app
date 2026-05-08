import 'package:flutter/material.dart';

/// A simple opening-hours window for one day. `start` and `end` are stored
/// as [TimeOfDay] for cheap rendering with the framework's time picker.
class DailyTimeRange {
  const DailyTimeRange({required this.start, required this.end});

  final TimeOfDay start;
  final TimeOfDay end;

  DailyTimeRange copyWith({TimeOfDay? start, TimeOfDay? end}) {
    return DailyTimeRange(start: start ?? this.start, end: end ?? this.end);
  }

  String format(BuildContext context) {
    final s = start.format(context);
    final e = end.format(context);
    return '$s — $e';
  }
}
