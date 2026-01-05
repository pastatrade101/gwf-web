import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'onboarding_screen.dart';
import 'core/constants/app_dimens.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  Future<void> _completeOnboarding() async {
    await OnboardingStore.setDone();
    Get.offAll(() => const AppShell());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: AppDimens.launcherIcon, color: Colors.white),
            const SizedBox(height: AppDimens.xl),
            const Text(
              'You are ready to go!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: AppDimens.xxl),
            ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.xxl, vertical: AppDimens.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            )
          ],
        ),
      ),
    );
  }
}
