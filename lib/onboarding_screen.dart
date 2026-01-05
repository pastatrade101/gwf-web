import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimens.dart';
import 'core/constants/app_text_styles.dart';


class OnboardingStore {
  static final _box = GetStorage();
  static const _key = 'onboarding_completed';
  static const _legacyKey = 'seenOnboarding';

  static bool get isDone =>
      _box.read(_key) == true || _box.read(_legacyKey) == true;

  static Future<void> setDone() async {
    await _box.write(_key, true);
    await _box.write(_legacyKey, true);
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  int _index = 0;

  final List<_OnboardItem> _pages = const [
    _OnboardItem(
      icon: Icons.public_rounded,
      title: "Welcome",
      subtitle: "Access services and information easily.",
    ),
    _OnboardItem(
      icon: Icons.layers_rounded,
      title: "Land Sales",
      subtitle: "Browse open land and sold land by councils.",
    ),
    _OnboardItem(
      icon: Icons.security_rounded,
      title: "Official & Secure",
      subtitle: "Information is sourced from official systems.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingStore.setDone();
    Get.offAll(() => const AppShell());
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bg;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.sm,
                AppDimens.pagePadding,
                AppDimens.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: AppDimens.navIconSize),
                  Text("Welcome", style: AppTextStyles.appBar.copyWith(color: text)),
                  TextButton(
                    onPressed: _finish,
                    child: Text("Skip", style: AppTextStyles.link),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePadding,
                    AppDimens.pagePadding,
                    AppDimens.pagePadding,
                    0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.xxl),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppDimens.heroIconSize,
                          height: AppDimens.heroIconSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimens.radius3xl),
                          ),
                          child: Icon(_pages[i].icon, size: AppDimens.heroIconInner, color: AppColors.primary),
                        ),
                        const SizedBox(height: AppDimens.xxl),
                        Text(
                          _pages[i].title,
                          style: AppTextStyles.headline.copyWith(color: text),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          _pages[i].subtitle,
                          style: AppTextStyles.bodyMuted.copyWith(color: muted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Dots
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.pagePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: AppDimens.xxs),
                    width: active ? AppDimens.dotActive : AppDimens.dotSize,
                    height: AppDimens.dotSize,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : border,
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                    ),
                  );
                }),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.lg,
                AppDimens.pagePadding,
                AppDimens.xxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _index == 0
                        ? const SizedBox.shrink()
                        : OutlinedButton(
                      onPressed: _back,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                        side: BorderSide(color: border),
                      ),
                      child: Text("Back", style: TextStyle(color: text, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  if (_index != 0) const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                      ),
                      child: Text(
                        _index == _pages.length - 1 ? "Get Started" : "Next",
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
