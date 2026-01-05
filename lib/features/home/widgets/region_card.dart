
import 'package:flutter/material.dart';
import 'package:myapp/data/models/region.dart';
import 'package:myapp/features/home/widgets/council_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

class RegionCard extends StatelessWidget {
  final Region region;

  const RegionCard({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.xl, vertical: AppDimens.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
      elevation: 0,
      color: theme.cardColor,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            region.name[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          region.name,
          style: AppTextStyles.sectionTitle,
        ),
        subtitle: Text(
          '${region.councils.length} councils',
          style: AppTextStyles.bodyMuted.copyWith(color: muted),
        ),
        children: region.councils
            .map((council) => CouncilTile(council: council))
            .toList(),
      ),
    );
  }
}
