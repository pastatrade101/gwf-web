import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../controllers/tovuti_controller.dart';
import 'tovuti_detail_page.dart';

class WebsitesPage extends StatelessWidget {
  WebsitesPage({super.key});

  final WebsitesController c = Get.put(WebsitesController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: Text("Tovuti / Websites", style: AppTextStyles.appBar),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: AppColors.text),
              onPressed: () => c.loadSeed(),
            ),
          ],
          bottom: TabBar(
            onTap: (i) => c.tabIndex.value = i,
            labelColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
            unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMutedDark
                : AppColors.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900),
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Regions"),
              Tab(text: "Councils"),
              Tab(text: "Districts"),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.sm, AppDimens.pagePadding, 0),
            child: Column(
              children: [
                _SearchBox(
                  hint: "Search regions, councils, districts...",
                  onChanged: (v) => c.query.value = v,
                ),
                const SizedBox(height: AppDimens.md),

                Expanded(
                  child: TabBarView(
                    children: [
                      _RegionsTab(),
                      _UnitsTab(type: AdminUnitType.council),
                      _UnitsTab(type: AdminUnitType.district),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WebsitesController c = Get.find<WebsitesController>();

    return Obx(() {
      final list = c.filteredRegions;

      if (list.isEmpty) {
        return Center(child: Text("No results", style: AppTextStyles.bodyMuted));
      }

      return ListView.separated(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + AppDimens.lgPlus,
        ),
        itemCount: list.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Obx(() {
              return _DirectoryCard(
                regions: c.totalRegions,
                councils: c.totalCouncils,
                districts: c.totalDistricts,
                expanded: c.showDirectoryDetails.value,
                onToggle: c.toggleDirectoryDetails,
              );
            });
          }
          return _RegionCard(region: list[i - 1]);
        },
      );
    });
  }
}

class _UnitsTab extends StatelessWidget {
  const _UnitsTab({required this.type});
  final AdminUnitType type;

  @override
  Widget build(BuildContext context) {
    final WebsitesController c = Get.find<WebsitesController>();

    return Obx(() {
      final list = c.filteredByType(type);

      if (list.isEmpty) {
        return Center(child: Text("No results", style: AppTextStyles.bodyMuted));
      }

      return ListView.separated(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + AppDimens.lgPlus,
        ),
        itemCount: list.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Obx(() {
              return _DirectoryCard(
                regions: c.totalRegions,
                councils: c.totalCouncils,
                districts: c.totalDistricts,
                expanded: c.showDirectoryDetails.value,
                onToggle: c.toggleDirectoryDetails,
              );
            });
          }
          return _UnitRow(item: list[i - 1]);
        },
      );
    });
  }
}

/// ===============================
/// UI Widgets
/// ===============================

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      height: AppDimens.fieldHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: border),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMuted.copyWith(color: muted),
          prefixIcon: Icon(Icons.search_rounded, color: muted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.lg,
          ),
        ),
      ),
    );
  }
}

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.regions,
    required this.councils,
    required this.districts,
    required this.expanded,
    required this.onToggle,
  });

  final int regions;
  final int councils;
  final int districts;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.md, AppDimens.md, AppDimens.md),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: border),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "DIRECTORY",
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: text,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: AppDimens.md,
              runSpacing: AppDimens.md,
              children: [
                _DirStat(title: "Regions", value: "$regions"),
                _DirStat(title: "Councils", value: "$councils"),
                _DirStat(title: "Districts", value: "$districts"),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: AppDimens.smPlus),
              Text(
                "Tap any card to view details. Open websites from the link inside.",
                style: TextStyle(color: muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DirStat extends StatelessWidget {
  const _DirStat({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.smPlus),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppDimens.xxxs),
          Text(
            title,
            style: TextStyle(color: muted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({required this.region});
  final RegionSites region;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Material(
      color: card,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: () => Get.to(() => TovutiDetailPage.region(region)),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.iconBoxMd,
                height: AppDimens.iconBoxMd,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(Icons.location_on_rounded, color: AppColors.accent, size: AppDimens.iconLg),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.regionName,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: AppDimens.xxs),
                    Text(
                      "${region.councils.length} councils • ${region.districts.length} districts",
                      style: AppTextStyles.bodyMuted.copyWith(color: muted),
                    ),
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

String prettyUrl(String url) {
  var u = url.replaceAll('https://', '').replaceAll('http://', '');
  if (u.endsWith('/')) u = u.substring(0, u.length - 1);
  return u;
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.item});
  final AdminUnitSite item;

  @override
  Widget build(BuildContext context) {
    final url = (item.website ?? '').trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Material(
      color: card,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        onTap: () => Get.to(() => TovutiDetailPage.unit(item)),
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
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
                ),
                child: Icon(
                  item.type == AdminUnitType.council ? Icons.account_balance_rounded : Icons.map_rounded,
                  color: AppColors.primary,
                  size: AppDimens.iconMd,
                ),
              ),
              const SizedBox(width: AppDimens.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: AppDimens.xxs),
                    Text(
                      url.isEmpty ? "Website not available" : prettyUrl(url),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted,
                    ),
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
