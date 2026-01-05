import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'app/theme_controller.dart';
import 'app/language_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/ui/app_scroll_behavior.dart';

import 'onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController(), permanent: true);
    final languageController = Get.put(LanguageController(), permanent: true);

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Gov Services",
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: themeController.themeMode.value,
      translations: AppTranslations(),
      locale: languageController.locale.value,
      fallbackLocale: const Locale('en', 'US'),
      scrollBehavior: const AppScrollBehavior(),
      home: const _RootGate(),
    ));
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    return OnboardingStore.isDone ? const AppShell() : const OnboardingScreen();
  }
}
