import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/news_controller.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/localization/category_localizer.dart';
import '../widgets/news_widgets.dart';
import 'news_detail.dart';

class FeaturedNewsPage extends StatelessWidget {
  const FeaturedNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "featured_news".tr,
          style: AppTextStyles.appBar,
        ),
      ),
      body: Obx(() {
        final isLoading = controller.loading.value;
        final err = controller.error.value;
        final list = controller.featuredOnly;

        if (isLoading) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: const NewsShimmer(),
          );
        }

        if (err.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
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

        if (list.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              children: [
                const SizedBox(height: AppDimens.xl),
                Text(
                  '${"no_updates_found".tr} "${CategoryLocalizer.label("featured_news".tr)}".',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePadding,
              AppDimens.lg,
              AppDimens.pagePadding,
              AppDimens.lg,
            ),
            itemBuilder: (context, index) {
              final item = list[index];
              return RecentTile(
                item: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => NewsDetailPagePro(news: item)),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
            itemCount: list.length,
          ),
        );
      }),
    );
  }
}
