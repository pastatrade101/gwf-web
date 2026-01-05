import 'package:flutter/material.dart';


import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/shimmer.dart';

class BannerSliderShimmer extends StatelessWidget {
  final double height;

  const BannerSliderShimmer({
    super.key,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
          child: ProShimmer(
            radius: AppDimens.radiusXl,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.smPlus),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
                (_) => Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.xxs),
              height: AppDimens.dotSmall,
              width: AppDimens.dotWide,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
