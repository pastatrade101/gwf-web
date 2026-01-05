import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/utils/shimmer.dart';


class ProNetworkImage extends StatelessWidget {
  final String? url;
  final double radius;
  final BoxFit fit;

  const ProNetworkImage({
    super.key,
    required this.url,
    this.radius = AppDimens.radiusLg,
    this.fit = BoxFit.cover,
  });

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fallbackBg = theme.cardColor;
    final iconColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final shimmerBase = theme.dividerColor;
    final fallback = Container(
      color: fallbackBg,
      child: Center(
        child: Icon(Icons.image_outlined, color: iconColor),
      ),
    );

    if (!_hasUrl) {
      return ClipRRect(borderRadius: BorderRadius.circular(radius), child: fallback);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url!.trim(),
        fit: fit,
        loadingBuilder: (context, child, prog) {
          if (prog == null) return child;
          return ProShimmer(radius: radius, child: Container(color: shimmerBase));
        },
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
