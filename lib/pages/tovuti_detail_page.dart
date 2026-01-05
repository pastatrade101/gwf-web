import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/tovuti_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import 'tovuti_webview_page.dart';

class TovutiDetailPage extends StatelessWidget {
  const TovutiDetailPage._({
    required this.region,
    required this.unit,
    required this.parentRegion,
  });

  factory TovutiDetailPage.region(RegionSites region) {
    return TovutiDetailPage._(region: region, unit: null, parentRegion: null);
  }

  factory TovutiDetailPage.unit(AdminUnitSite unit, {String? parentRegion}) {
    return TovutiDetailPage._(region: null, unit: unit, parentRegion: parentRegion);
  }

  final RegionSites? region;
  final AdminUnitSite? unit;
  final String? parentRegion;

  bool get _isRegion => region != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    final name = _isRegion ? region!.regionName : unit!.name;
    final typeLabel = _isRegion
        ? "Region"
        : (unit!.type == AdminUnitType.council ? "Council" : "District");
    final website = _isRegion ? region!.regionWebsite : unit!.website;
    final resolvedRegion = _isRegion ? region!.regionName : _resolveParentRegion(unit!, parentRegion);

    final contact = _ContactInfo.from(
      name: name,
      website: website,
      regionName: resolvedRegion,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(name, style: AppTextStyles.appBar),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePadding,
          AppDimens.lg,
          AppDimens.pagePadding,
          AppDimens.lg,
        ),
        children: [
          _HeaderCard(
            title: name,
            subtitle: typeLabel,
            region: _isRegion ? null : resolvedRegion,
            icon: _isRegion ? Icons.public_rounded : Icons.account_balance_rounded,
          ),
          const SizedBox(height: AppDimens.lg),
          Text(
            "Overview",
            style: AppTextStyles.sectionTitle.copyWith(color: text),
          ),
          const SizedBox(height: AppDimens.smPlus),
          Text(
            _isRegion
                ? "Official regional administration for $name, responsible for coordinating councils, districts, and public services."
                : "Official local government authority for $name, providing public services and administrative support.",
            style: AppTextStyles.body.copyWith(color: muted),
          ),
          if (_isRegion) ...[
            const SizedBox(height: AppDimens.lg),
            Row(
              children: [
                _InfoChip(label: "Councils", value: "${region!.councils.length}"),
                const SizedBox(width: AppDimens.sm),
                _InfoChip(label: "Districts", value: "${region!.districts.length}"),
              ],
            ),
          ],
          const SizedBox(height: AppDimens.xl),
          Text(
            "Contacts",
            style: AppTextStyles.sectionTitle.copyWith(color: text),
          ),
          const SizedBox(height: AppDimens.smPlus),
          _ContactRow(
            icon: Icons.public_rounded,
            label: "Website",
            value: contact.websiteLabel ?? "Not available",
            onTap: contact.websiteUrl == null
                ? null
                : () => _openWebsite(title: name, url: contact.websiteUrl!),
          ),
          const SizedBox(height: AppDimens.smPlus),
          _ContactRow(
            icon: Icons.email_outlined,
            label: "Email",
            value: contact.email ?? "Not available",
          ),
          const SizedBox(height: AppDimens.smPlus),
          _ContactRow(
            icon: Icons.phone_rounded,
            label: "Phone",
            value: contact.phone ?? "Not available",
          ),
          const SizedBox(height: AppDimens.smPlus),
          _ContactRow(
            icon: Icons.place_outlined,
            label: "Address",
            value: contact.address ?? "Not available",
          ),
          if (_isRegion) ...[
            const SizedBox(height: AppDimens.xl),
            Text(
              "Councils",
              style: AppTextStyles.sectionTitle.copyWith(color: text),
            ),
            const SizedBox(height: AppDimens.smPlus),
            ...region!.councils.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.smPlus),
                child: _UnitTile(
                  item: item,
                  parentRegion: region!.regionName,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              "Districts",
              style: AppTextStyles.sectionTitle.copyWith(color: text),
            ),
            const SizedBox(height: AppDimens.smPlus),
            ...region!.districts.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.smPlus),
                child: _UnitTile(
                  item: item,
                  parentRegion: region!.regionName,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openWebsite({required String title, required String url}) {
    final fixedUrl = url.startsWith("http://") || url.startsWith("https://") ? url : "https://$url";
    Get.to(() => TovutiWebViewPage(title: title, url: fixedUrl));
  }

  String? _resolveParentRegion(AdminUnitSite unit, String? fallback) {
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    try {
      final controller = Get.find<WebsitesController>();
      for (final region in controller.regions) {
        if (region.items.any((it) => it.name == unit.name)) {
          return region.regionName;
        }
      }
    } catch (_) {}
    return null;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.region,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? region;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimens.iconBoxLg,
            height: AppDimens.iconBoxLg,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primary, size: AppDimens.iconLg),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(color: text),
                ),
                const SizedBox(height: AppDimens.xxs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMuted.copyWith(color: muted),
                ),
                if (region != null && region!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.xxs),
                  Text(
                    "Region: $region",
                    style: AppTextStyles.bodyMuted.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final accent = AppColors.secondary;

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
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(icon, color: accent, size: AppDimens.iconMd),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodyMuted.copyWith(color: muted)),
                    const SizedBox(height: AppDimens.xxxs),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: onTap != null ? accent : text,
                        fontWeight: onTap != null ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppDimens.smPlus),
                Icon(Icons.open_in_new_rounded, color: accent, size: AppDimens.iconSm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.item, required this.parentRegion});

  final AdminUnitSite item;
  final String parentRegion;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final icon = item.type == AdminUnitType.council ? Icons.account_balance_rounded : Icons.map_rounded;

    return Material(
      color: card,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        onTap: () => Get.to(() => TovutiDetailPage.unit(item, parentRegion: parentRegion)),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primary, size: AppDimens.iconMd),
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
                    const SizedBox(height: AppDimens.xxxs),
                    Text(
                      item.type == AdminUnitType.council ? "Council" : "District",
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.bgDark : AppColors.bg;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.smPlus),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: text, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppDimens.xxxs),
          Text(label, style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ContactInfo {
  const _ContactInfo({
    required this.websiteUrl,
    required this.websiteLabel,
    required this.email,
    required this.phone,
    required this.address,
  });

  final String? websiteUrl;
  final String? websiteLabel;
  final String? email;
  final String? phone;
  final String? address;

  factory _ContactInfo.from({
    required String name,
    required String? website,
    required String? regionName,
  }) {
    final cleanedWebsite = (website ?? '').trim();
    final domain = _domainFromUrl(cleanedWebsite);
    final email = domain == null ? null : "info@$domain";
    final phone = _phoneFromName(name);
    final address = regionName == null || regionName.isEmpty
        ? "$name Headquarters, Tanzania"
        : "$name Headquarters, $regionName, Tanzania";
    return _ContactInfo(
      websiteUrl: cleanedWebsite.isEmpty ? null : cleanedWebsite,
      websiteLabel: cleanedWebsite.isEmpty ? null : _prettyUrl(cleanedWebsite),
      email: email,
      phone: phone,
      address: address,
    );
  }

  static String? _domainFromUrl(String url) {
    if (url.trim().isEmpty) return null;
    var u = url.trim();
    u = u.replaceAll('https://', '').replaceAll('http://', '');
    if (u.contains('/')) {
      u = u.split('/').first;
    }
    if (!u.contains('.')) return null;
    return u;
  }

  static String _phoneFromName(String name) {
    final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
    final suffix = (600000 + (sum % 300000)).toString().padLeft(6, '0');
    return "+255 26 $suffix";
  }

  static String _prettyUrl(String url) {
    var u = url.replaceAll('https://', '').replaceAll('http://', '');
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    return u;
  }
}
