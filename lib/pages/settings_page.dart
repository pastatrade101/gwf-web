import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/theme_controller.dart';
import '../app/language_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import 'chatbot_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();
    final langC = Get.find<LanguageController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
        elevation: 0,
        title: Text("settings".tr, style: AppTextStyles.appBar),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePadding,
          AppDimens.md,
          AppDimens.pagePadding,
          AppDimens.lg,
        ),
        children: [
          Text("appearance".tr, style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppDimens.sm),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.sm, AppDimens.md, AppDimens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "theme".tr,
                      style: AppTextStyles.bodyMuted.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeChip(
                            icon: Icons.phone_iphone_rounded,
                            semanticLabel: "System",
                            selected: themeC.themeMode.value == ThemeMode.system,
                            onTap: () => themeC.setThemeMode(ThemeMode.system),
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: _ThemeChip(
                            icon: Icons.light_mode_rounded,
                            semanticLabel: "Light",
                            selected: themeC.themeMode.value == ThemeMode.light,
                            onTap: () => themeC.setThemeMode(ThemeMode.light),
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: _ThemeChip(
                            icon: Icons.dark_mode_rounded,
                            semanticLabel: "Dark",
                            selected: themeC.themeMode.value == ThemeMode.dark,
                            onTap: () => themeC.setThemeMode(ThemeMode.dark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimens.lg),
          Text("language".tr, style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppDimens.sm),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.sm, AppDimens.md, AppDimens.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _LangChip(
                        label: "EN",
                        selected: !langC.isSwahili,
                        onTap: () => langC.setLocale(const Locale('en', 'US')),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: _LangChip(
                        label: "SW",
                        selected: langC.isSwahili,
                        onTap: () => langC.setLocale(const Locale('sw', 'TZ')),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimens.lg),
          Text("Support", style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppDimens.sm),
          _SettingsLink(
            title: "GWF Assistant",
            subtitle: "Ask questions from official info",
            icon: Icons.support_agent_rounded,
            onTap: () => Get.to(() => ChatbotPage()),
          ),
        ],
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Material(
      color: card,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.iconBoxSm,
                height: AppDimens.iconBoxSm,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(icon, color: AppColors.secondary, size: AppDimens.iconMd),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
                    const SizedBox(height: AppDimens.xxxs),
                    Text(subtitle, style: AppTextStyles.bodyMuted.copyWith(color: muted)),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.smPlus),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.icon,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.18)
        : (isDark ? AppColors.bgDark : AppColors.bg);
    final border = selected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border);
    final text = selected
        ? AppColors.primary
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: AppDimens.iconMd, color: text),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.18)
        : (isDark ? AppColors.bgDark : AppColors.bg);
    final border = selected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border);
    final text = selected
        ? AppColors.primary
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.translate_rounded, size: AppDimens.iconSm, color: text),
            const SizedBox(width: AppDimens.xs),
            Text(
              label,
              style: AppTextStyles.body.copyWith(color: text, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
