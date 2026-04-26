import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Persisted tri-state theme preference: System / Light / Dark.
///
/// Reads/writes the choice to [GetStorage] so the user's selection survives
/// app restarts. App-level wiring lives in [App.build].
class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  static const _key = 'themeMode';
  final _storage = GetStorage();

  late final Rx<ThemeMode> mode = _loadFromStorage().obs;

  ThemeMode _loadFromStorage() {
    final raw = _storage.read<String>(_key);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  void setMode(ThemeMode next) {
    mode.value = next;
    _storage.write(_key, next.name);
    Get.changeThemeMode(next);
  }
}
