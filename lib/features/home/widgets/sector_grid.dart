import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

class SectorGrid extends StatelessWidget {
  const SectorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _SectorItem("Healthcare", "Hospitals, Clinics,\nMental Health", Icons.medical_services_rounded),
      _SectorItem("Education", "Schools, Grants,\nUniversities", Icons.school_rounded),
      _SectorItem("Public Safety", "Police, Fire,\nEmergency", Icons.shield_rounded),
      _SectorItem("Transport", "Licenses, Transit,\nRoad Services", Icons.directions_bus_rounded),
      _SectorItem("Social Services", "Housing, Employment,\nBenefits", Icons.groups_rounded),
      _SectorItem("Legal & ID", "Passports, ID Cards,\nCertificates", Icons.fingerprint_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.18, // ✅ FIX: more vertical room
      ),
      itemBuilder: (_, i) => _SectorCard(item: items[i]),
    );
  }
}

class _SectorItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectorItem(this.title, this.subtitle, this.icon);
}

class _SectorCard extends StatelessWidget {
  final _SectorItem item;
  const _SectorCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = theme.cardColor;
    final border = theme.dividerColor;
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: () {
          // TODO: navigate to sector page
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                height: AppDimens.iconBoxMd,
                width: AppDimens.iconBoxMd,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(item.icon, color: AppColors.accent, size: AppDimens.iconLg),
              ),

              const SizedBox(height: AppDimens.smPlus),

              // Title (max 1–2 lines)
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionTitle,
              ),

              const SizedBox(height: AppDimens.xs),

              // ✅ FIX: Flexible subtitle
              Expanded(
                child: Text(
                  item.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
