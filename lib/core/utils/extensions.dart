import 'package:incacook/core/utils/validation_utils.dart';

extension StringExtensions on String {
  bool get isEmail => ValidationUtils.isValidEmail(this);

  String get capitalize =>
      isNotEmpty ? this[0].toUpperCase() + substring(1) : this;
}

extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }
}
