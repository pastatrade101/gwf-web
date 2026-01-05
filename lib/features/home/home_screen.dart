import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

import 'widgets/banner_slider.dart';
import 'widgets/banner_slider_shimmer.dart';
import 'widgets/sector_grid.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController c = Get.put(HomeController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text("service_categories".tr, style: AppTextStyles.appBar),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePadding,
            AppDimens.md,
            AppDimens.pagePadding,
            AppDimens.lg,
          ),
          children: [
            SearchBox(
              controller: searchController,
              hint: "search_services".tr,
              onChanged: c.onSearchChanged,
            ),
            const SizedBox(height: AppDimens.md),

            // Slider
            Obx(() {
              if (c.isBannerLoading.value) return const BannerSliderShimmer();

              if (c.bannerError.value != null) {
                return Container(
                  padding: const EdgeInsets.all(AppDimens.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    "Banner error:\n${c.bannerError.value}",
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                );
              }

              if (c.banners.isEmpty) return const SizedBox.shrink();
              return BannerSlider(banners: c.banners, height: AppDimens.bannerHeight);
            }),

            const SizedBox(height: AppDimens.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("browse_by_sector".tr, style: AppTextStyles.sectionTitle),
                Text("view_all".tr, style: AppTextStyles.link),
              ],
            ),
            const SizedBox(height: AppDimens.md),

            const SectorGrid(),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
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
        controller: controller,
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
