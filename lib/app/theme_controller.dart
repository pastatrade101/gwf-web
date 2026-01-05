import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/constants/app_theme.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();

  final themeMode = ThemeMode.system.obs;

  ThemeData get lightTheme => AppTheme.light;

  ThemeData get darkTheme => AppTheme.dark;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read('themeMode');
    if (saved == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (saved == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  bool get isDark => themeMode.value == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    if (mode == ThemeMode.system) {
      _box.remove('themeMode');
      return;
    }
    _box.write('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggleTheme() {
    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
