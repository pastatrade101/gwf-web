import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/news_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/localization/category_localizer.dart';
import '../widgets/news_widgets.dart';
import 'featured_news_page.dart';
import 'news_detail.dart';

class LatestNewsPagePro extends StatefulWidget {
  const LatestNewsPagePro({super.key});

  @override
  State<LatestNewsPagePro> createState() => _LatestNewsPageProState();
}

class _LatestNewsPageProState extends State<LatestNewsPagePro> {
  late final NewsController c;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    c = Get.put(NewsController(), permanent: true); // ✅ put once
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          // ✅ MUST read Rx values inside Obx
          final isLoading = c.loading.value;
          final err = c.error.value;

          if (isLoading) {
            return RefreshIndicator(
              onRefresh: c.refresh,
              child: const NewsShimmer(),
            );
          }
          if (err.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: c.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                children: [
                  const SizedBox(height: AppDimens.xl),
                  Text(
                    "Failed to load news:\n$err",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final featuredItems = c.featuredItems;
          final recent = c.recent;     // depends on Rx internally

          final visible = c.visibleRecent;
          final hasMore = c.hasMore;

          return RefreshIndicator(
            onRefresh: c.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  c.loadMore();
                }
                return false;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePadding,
                  AppDimens.xs,
                  AppDimens.pagePadding,
                  AppDimens.lg,
                ),
                children: [
              Text(
                "latest_news".tr,
                style: AppTextStyles.link,

              ),
              const SizedBox(height: AppDimens.md),

              if (featuredItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "featured_news".tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.brightness == Brightness.dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const FeaturedNewsPage()),
                      child: Text(
                        "view_all".tr,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.smPlus),
                SizedBox(
                  height: AppDimens.featuredSliderHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: featuredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppDimens.md),
                    itemBuilder: (context, i) {
                      final item = featuredItems[i];
                      return HomePageAnimation(
                        child: FeaturedSliderCard(
                          item: item,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => NewsDetailPagePro(news: item)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
              ],

              NewsSearchBox(
                controller: _searchCtrl,
                onChanged: c.onSearchChanged, // debounced
              ),
              const SizedBox(height: AppDimens.pagePadding),

              SizedBox(
                height: AppDimens.chipRowHeight,
                child: Obx(() {
                  final active = c.activeTab.value; // ✅ Rx used here
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final chipText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: c.tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppDimens.smPlus),
                    itemBuilder: (context, i) {
                      final isActive = i == active;
                      return ChoiceChip(
                        label: Text(CategoryLocalizer.tabLabel(c.tabs[i])),
                        labelStyle: isActive
                            ? AppTextStyles.chipActive
                            : AppTextStyles.chip.copyWith(color: chipText),
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                        selected: isActive,
                        showCheckmark: false,
                        onSelected: (_) => c.setTab(i),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: AppDimens.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "recent_updates".tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.brightness == Brightness.dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _FilterButton(controller: c),
                ],
              ),
              const SizedBox(height: AppDimens.smPlus),

              if (visible.isEmpty)
                Center(
                  child: Obx(() {
                    final tab = c.selectedTab; // ✅ reads activeTab.value internally
                    return Text('${"no_updates_found".tr} "${CategoryLocalizer.tabLabel(tab)}".');
                  }),
                )
              else
                ...visible.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                    child: RecentTile(
                      item: item,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => NewsDetailPagePro(news: item)),
                        );
                      },
                    ),
                  );
                }),
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimens.sm),
                  child: Center(
                    child: SizedBox(
                      width: AppDimens.iconBoxSm,
                      height: AppDimens.iconBoxSm,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.controller});

  final NewsController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showFilterSheet(context, controller),
      icon: const Icon(Icons.tune_rounded),
      tooltip: "filter".tr,
    );
  }

  void _showFilterSheet(BuildContext context, NewsController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      builder: (_) {
        return SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.sm,
                AppDimens.pagePadding,
                AppDimens.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("filter".tr, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppDimens.md),
                  Text("sort".tr, style: AppTextStyles.bodyMuted),
                  const SizedBox(height: AppDimens.xs),
                  _RadioTile(
                    label: "newest".tr,
                    value: "desc",
                    group: c.sortOrder.value,
                    onChanged: c.setSortOrder,
                  ),
                  _RadioTile(
                    label: "oldest".tr,
                    value: "asc",
                    group: c.sortOrder.value,
                    onChanged: c.setSortOrder,
                  ),
                  const SizedBox(height: AppDimens.md),
                Text("time_range".tr, style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppDimens.xs),
                _RadioTile(
                  label: "all_time".tr,
                  value: "all",
                  group: c.timeRange.value,
                    onChanged: c.setTimeRange,
                  ),
                  _RadioTile(
                    label: "last_7_days".tr,
                    value: "7d",
                    group: c.timeRange.value,
                    onChanged: c.setTimeRange,
                  ),
                  _RadioTile(
                    label: "last_30_days".tr,
                    value: "30d",
                  group: c.timeRange.value,
                  onChanged: c.setTimeRange,
                ),
                const SizedBox(height: AppDimens.md),
                Text("region".tr, style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppDimens.xs),
                _DropdownField(
                  value: c.regionFilter.value,
                  options: c.regionOptions,
                  onChanged: c.setRegionFilter,
                ),
                const SizedBox(height: AppDimens.md),
                Text("council".tr, style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppDimens.xs),
                _DropdownField(
                  value: c.councilFilter.value,
                  options: c.councilOptions,
                  onChanged: c.setCouncilFilter,
                ),
                const SizedBox(height: AppDimens.mdPlus),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            c.resetFilters();
                            Navigator.of(context).pop();
                          },
                          child: Text("reset".tr),
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("apply".tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.label,
    required this.value,
    required this.group,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String group;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: group,
      onChanged: (val) => onChanged(val ?? value),
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          dropdownColor: card,
          icon: Icon(Icons.expand_more_rounded, color: text),
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt == "All" ? "category.all".tr : opt,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => onChanged(val ?? value),
        ),
      ),
    );
  }
}
