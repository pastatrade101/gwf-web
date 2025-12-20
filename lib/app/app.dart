
import 'package:flutter/material.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/features/home/home_screen.dart';
import 'package:myapp/onboarding_screen.dart';

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanzania Regions & Councils',
      theme: appTheme,
      home: onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
