
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/features/home/home_screen.dart';
import 'package:myapp/onboarding_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final bool onboardingCompleted = box.read('onboarding_completed') ?? false;

    return GetMaterialApp(
      title: 'Tanzania Regions & Councils',
      theme: appTheme,
      home: onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
