import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import 'e_service_page.dart';


class EServiceDetailPage extends StatelessWidget {
  const EServiceDetailPage({super.key, required this.service});

  final EServiceModel service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            expandedHeight: 240,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: text),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.bookmark_border_rounded, color: text),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _HeroImage(url: service.heroUrl.isNotEmpty ? service.heroUrl : service.logoUrl),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppDimens.pagePadding,
                    right: AppDimens.pagePadding,
                    bottom: AppDimens.md,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Logo(url: service.logoUrl),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppDimens.xxs),
                              Text(
                                service.ministry.isEmpty ? "TAMISEMI / PO-RALG" : service.ministry,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMuted.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                              ),
                              const SizedBox(height: AppDimens.xs),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Pill(text: service.category, bg: Colors.white.withValues(alpha: 0.14), fg: Colors.white),
                                  _Pill(
                                    text: "Official Government Service",
                                    bg: AppColors.primary.withValues(alpha: 0.22),
                                    fg: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.md, AppDimens.pagePadding, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: "Service Summary"),
                  const SizedBox(height: AppDimens.sm),
                  _Card(
                    child: Text(
                      service.overview.isEmpty ? service.subtitle : service.overview,
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  _SectionTitle(title: "Who Should Use It"),
                  const SizedBox(height: AppDimens.sm),
                  _Card(
                    child: _ListOrPlaceholder(
                      items: service.eligibility,
                      placeholder: "Citizens and officials who need this service.",
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  _SectionTitle(title: "Requirements"),
                  const SizedBox(height: AppDimens.sm),
                  _Card(
                    child: _ListOrPlaceholder(
                      items: service.requiredDocs.map((e) => e.title).toList(),
                      placeholder: "Valid ID, internet access, and relevant documents.",
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  _SectionTitle(title: "How to Use the Service"),
                  const SizedBox(height: AppDimens.sm),
                  _Card(
                    child: _StepsOrPlaceholder(
                      steps: service.processSteps,
                      placeholder: const [
                        "Open the official portal.",
                        "Sign in or create an account.",
                        "Fill in the application form and submit.",
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  _SectionTitle(title: "Official Link"),
                  const SizedBox(height: AppDimens.sm),
                  _Card(
                    child: Row(
                      children: [
                        Icon(Icons.link_rounded, color: AppColors.primary),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(
                            service.portalUrl.isEmpty ? "Not provided" : service.portalUrl,
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  _SectionTitle(title: "Contact"),
                  const SizedBox(height: AppDimens.sm),
                  _Card(
                    child: Text(
                      "For support, contact your local council or TAMISEMI service desk.",
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppDimens.bottomSpacer)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.sm, AppDimens.pagePadding, AppDimens.md),
          decoration: BoxDecoration(
            color: card,
            border: Border(top: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share_outlined, color: muted),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: FilledButton(
                  onPressed: service.portalUrl.trim().isEmpty
                      ? null
                      : () {
                          Get.snackbar("Portal Link", service.portalUrl, snackPosition: SnackPosition.BOTTOM);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Open Official Portal", style: TextStyle(fontWeight: FontWeight.w900)),
                        SizedBox(width: AppDimens.smPlus),
                        Icon(Icons.open_in_new_rounded, size: AppDimens.iconSm),
                      ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.sectionTitle);
  }
}

class _ListOrPlaceholder extends StatelessWidget {
  const _ListOrPlaceholder({required this.items, required this.placeholder});
  final List<String> items;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(placeholder, style: AppTextStyles.body);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => _Bullet(text: e)).toList(),
    );
  }
}

class _StepsOrPlaceholder extends StatelessWidget {
  const _StepsOrPlaceholder({required this.steps, required this.placeholder});
  final List<StepItem> steps;
  final List<String> placeholder;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: placeholder.map((e) => _Bullet(text: e)).toList(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps
          .asMap()
          .entries
          .map((e) => _StepRow(index: e.key + 1, title: e.value.title, desc: e.value.description))
          .toList(),
    );
  }
}

/* ----------------------------- UI Bits ----------------------------- */

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});
  final String url;

  bool get _has => url.trim().isNotEmpty;
  bool get _isAsset => url.trim().startsWith("assets/");

  @override
  Widget build(BuildContext context) {
    if (!_has) {
      return Container(
        color: AppColors.primary.withValues(alpha: 0.15),
        child: const Center(
          child: Icon(Icons.public_rounded, size: AppDimens.heroPlaceholderIcon, color: Colors.white70),
        ),
      );
    }

    if (_isAsset) {
      return Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Center(
          child: Image.asset(url.trim(), fit: BoxFit.contain),
        ),
      );
    }

    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Center(
        child: Image.network(
          url.trim(),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.public_rounded,
            size: AppDimens.heroPlaceholderIcon,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url});
  final String url;

  bool get _has => url.trim().isNotEmpty;
  bool get _isAsset => url.trim().startsWith("assets/");

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: AppDimens.logoSize,
      height: AppDimens.logoSize,
      padding: const EdgeInsets.all(AppDimens.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Icon(Icons.apps_rounded, color: Colors.white.withValues(alpha: 0.9)),
    );

    if (!_has) return box;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: _isAsset
          ? Container(
              width: AppDimens.logoSize,
              height: AppDimens.logoSize,
              padding: const EdgeInsets.all(AppDimens.xs),
              color: Colors.white.withValues(alpha: 0.18),
              child: Image.asset(
                url.trim(),
                fit: BoxFit.contain,
              ),
            )
          : Container(
              width: AppDimens.logoSize,
              height: AppDimens.logoSize,
              padding: const EdgeInsets.all(AppDimens.xs),
              color: Colors.white.withValues(alpha: 0.18),
              child: Image.network(
                url.trim(),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => box,
              ),
            ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.smPlus),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimens.iconChip,
            height: AppDimens.iconChip,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
            child: Icon(Icons.check_rounded, size: AppDimens.bulletIcon, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimens.smPlus),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.title, required this.desc});
  final int index;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: AppDimens.stepDot,
                height: AppDimens.stepDot,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                ),
              ),
              Container(width: AppDimens.lineThickness, height: AppDimens.stepLineHeight, color: theme.dividerColor),
            ],
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
                const SizedBox(height: AppDimens.xxs),
                Text(desc, style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
