import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

class ServicesListPage extends StatelessWidget {
  const ServicesListPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.appBar),
        centerTitle: true,
        backgroundColor: bg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.md, AppDimens.pagePadding, AppDimens.lg),
        children: [
          _SearchBox(),
          const SizedBox(height: AppDimens.md),
          _ChipRow(),
          const SizedBox(height: AppDimens.mdPlus),
          Text("AVAILABLE SERVICES", style: AppTextStyles.mutedCaps),
          const SizedBox(height: AppDimens.smPlus),
          ..._tiles(),
        ],
      ),
    );
  }

  List<Widget> _tiles() {
    final items = [
      ("National Vaccination Program", "Ministry of Health", Icons.vaccines),
      ("Maternal Care Grant", "Ministry of Social Development", Icons.emoji_emotions),
      ("Public Hospital Registration", "Ministry of Health", Icons.local_hospital),
      ("Senior Citizen Card", "Dept. of Elder Affairs", Icons.elderly),
      ("Mental Health Support", "National Wellness Center", Icons.health_and_safety),
      ("Emergency Ambulance Svc", "Emergency Response Unit", Icons.emergency),
    ];

    return items.map((e) => _ServiceTile(
      title: e.$1,
      subtitle: e.$2,
      icon: e.$3,
    )).toList();
  }
}

class _SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final card = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Container(
      height: AppDimens.fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: muted),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search services...",
                hintStyle: AppTextStyles.bodyMuted.copyWith(color: muted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chips = ["All", "Hospitals", "Grants", "Insurance"];
    return SizedBox(
      height: AppDimens.chipRowHeightSm,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.smPlus),
        itemBuilder: (_, i) {
          final active = i == 0;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final card = Theme.of(context).cardColor;
          final border = Theme.of(context).dividerColor;
          return ChoiceChip(
            label: Text(chips[i]),
            selected: active,
            showCheckmark: false,
            selectedColor: AppColors.secondary,
            backgroundColor: card,
            labelStyle: active
                ? AppTextStyles.chipActive
                : AppTextStyles.chip,
            shape: StadiumBorder(
              side: BorderSide(color: active ? Colors.transparent : border),
            ),
            onSelected: (_) {},
          );
        },
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.iconBoxLg,
            height: AppDimens.iconBoxLg,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(icon, color: AppColors.secondary),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.tileTitle),
                const SizedBox(height: AppDimens.xxxs),
                Text(subtitle, style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: muted),
        ],
      ),
    );
  }
}
