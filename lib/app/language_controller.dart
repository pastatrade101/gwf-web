import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LanguageController extends GetxController {
  static const _storageKey = 'app_locale';
  final _box = GetStorage();

  final Rx<Locale> locale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String>(_storageKey);
    if (saved == 'sw') {
      locale.value = const Locale('sw', 'TZ');
    } else {
      locale.value = const Locale('en', 'US');
    }
    Get.updateLocale(locale.value);
  }

  bool get isSwahili => locale.value.languageCode == 'sw';

  void setLocale(Locale newLocale) {
    locale.value = newLocale;
    _box.write(_storageKey, newLocale.languageCode);
    Get.updateLocale(newLocale);
  }
}
