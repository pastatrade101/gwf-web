import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/models/news_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/localization/category_localizer.dart';

/// ----------------------- Helpers: date text -----------------------
String newsTimeText(DateTime? dt) {
  if (dt == null) return "—";
  final now = DateTime.now();
  final d = DateTime(dt.year, dt.month, dt.day);
  final n = DateTime(now.year, now.month, now.day);
  final diff = n.difference(d).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";
  if (diff < 7) return "$diff days ago";

  final mm = dt.month.toString().padLeft(2, '0');
  final dd = dt.day.toString().padLeft(2, '0');
  return "${dt.year}-$mm-$dd";
}

String newsDateText(DateTime? dt) {
  if (dt == null) return "—";
  final mm = dt.month.toString().padLeft(2, '0');
  final dd = dt.day.toString().padLeft(2, '0');
  return "${dt.year}-$mm-$dd";
}

/// ------------------------------------------------------------
/// HomePageAnimation (your exact class)
/// ------------------------------------------------------------
class HomePageAnimation extends StatefulWidget {
  final Widget child;
  const HomePageAnimation({super.key, required this.child});

  @override
  State<HomePageAnimation> createState() => _HomePageAnimationState();
}

class _HomePageAnimationState extends State<HomePageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}

/// ------------------------------------------------------------
/// ProStagger
/// ------------------------------------------------------------
class ProStagger extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const ProStagger({super.key, required this.child, this.delayMs = 0});

  @override
  State<ProStagger> createState() => _ProStaggerState();
}

class _ProStaggerState extends State<ProStagger> {
  bool _show = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        final slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        );
        return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
      },
      child: _show ? widget.child : const SizedBox.shrink(),
    );
  }
}

/// ------------------------------------------------------------
/// ProShimmer
/// ------------------------------------------------------------
class ProShimmer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  const ProShimmer({super.key, required this.child, this.borderRadius = AppDimens.radiusMd});

  @override
  State<ProShimmer> createState() => _ProShimmerState();
}

class _ProShimmerState extends State<ProShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.cardDark : AppColors.card;
    final shimmer = isDark ? 0.18 : 0.35;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (rect) {
                    final t = _c.value;
                    return LinearGradient(
                      begin: Alignment(-1.0 - 0.2 + (t * 2.4), 0),
                      end: Alignment(-0.2 + (t * 2.4), 0),
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: shimmer),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.25, 0.5, 0.75],
                    ).createShader(rect);
                  },
                  child: Container(color: base),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------
/// ProNetworkImage
/// ------------------------------------------------------------
class ProNetworkImage extends StatelessWidget {
  const ProNetworkImage({
    super.key,
    required this.url,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String? url;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fallbackBg = theme.cardColor;
    final iconColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final shimmerBase = theme.dividerColor;
    final ph = placeholder ??
        Container(
          color: fallbackBg,
          child: Center(child: Icon(Icons.image_outlined, color: iconColor)),
        );

    if (!_hasUrl) {
      return ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: ph);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url!.trim(),
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ProShimmer(borderRadius: borderRadius, child: Container(color: shimmerBase));
        },
        errorBuilder: (_, __, ___) => ph,
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Shimmer page skeleton
/// ------------------------------------------------------------
class NewsShimmer extends StatelessWidget {
  const NewsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePadding,
        AppDimens.xs,
        AppDimens.pagePadding,
        AppDimens.lg,
      ),
      children: const [
        ProShimmer(borderRadius: AppDimens.radiusSm, child: _ShimmerBox(height: AppDimens.shimmerTitleHeight, widthFactor: 0.55)),
        SizedBox(height: AppDimens.mdPlus),
        ProShimmer(borderRadius: AppDimens.radiusMd, child: _ShimmerBox(height: AppDimens.shimmerSearchHeight)),
        SizedBox(height: AppDimens.lg),
        ProShimmer(borderRadius: AppDimens.radiusPill, child: _ShimmerRowChips()),
        SizedBox(height: AppDimens.lg),
        ProShimmer(borderRadius: AppDimens.radiusXl, child: _ShimmerBox(height: AppDimens.shimmerHeroHeight)),
        SizedBox(height: AppDimens.lgPlus),
        ProShimmer(borderRadius: AppDimens.radiusSm, child: _ShimmerBox(height: AppDimens.shimmerSectionHeight, widthFactor: 0.45)),
        SizedBox(height: AppDimens.smPlus),
        ProShimmer(borderRadius: AppDimens.radiusLg, child: _ShimmerTile()),
        SizedBox(height: AppDimens.md),
        ProShimmer(borderRadius: AppDimens.radiusLg, child: _ShimmerTile()),
        SizedBox(height: AppDimens.md),
        ProShimmer(borderRadius: AppDimens.radiusLg, child: _ShimmerTile()),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.height, this.widthFactor = 1});
  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).cardColor;
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
        ),
      ),
    );
  }
}

class _ShimmerRowChips extends StatelessWidget {
  const _ShimmerRowChips();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).cardColor;
    return SizedBox(
      height: AppDimens.chipRowHeight,
      child: Row(
        children: [
          Expanded(child: _pill(base)),
          SizedBox(width: AppDimens.smPlus),
          Expanded(child: _pill(base)),
          SizedBox(width: AppDimens.smPlus),
          Expanded(child: _pill(base)),
        ],
      ),
    );
  }

  Widget _pill(Color base) => Container(
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(AppDimens.radiusPill)),
      );
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).cardColor;
    final line = Theme.of(context).dividerColor.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
      child: Row(
        children: [
          Container(
            width: AppDimens.recentThumbSize,
            height: AppDimens.recentThumbSize,
            decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: AppDimens.md, width: AppDimens.shimmerTitleWidth, color: line),
              const SizedBox(height: AppDimens.smPlus),
              Container(height: AppDimens.mdPlus, width: double.infinity, color: line),
              const SizedBox(height: AppDimens.xs),
              Container(height: AppDimens.md, width: double.infinity, color: line),
            ]),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Search box
/// ------------------------------------------------------------
class NewsSearchBox extends StatelessWidget {
  const NewsSearchBox({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final hint = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Container(
      height: AppDimens.fieldHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search updates...",
          prefixIcon: Icon(Icons.search_rounded, color: hint),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.lg,
          ),
          hintStyle: TextStyle(color: hint),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Featured card
/// ------------------------------------------------------------
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.item, required this.onReadFull});

  final NewsModel item;
  final VoidCallback onReadFull;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    final fallbackHero = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0F1A), Color(0xFF0E2B3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Icon(Icons.badge_outlined, size: AppDimens.featuredIconSize, color: Colors.white70)),
    );

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          SizedBox(
            height: AppDimens.featuredHeroHeight,
            width: double.infinity,
            child: ProNetworkImage(url: item.imageUrl, fit: BoxFit.cover, placeholder: fallbackHero),
          ),
          Positioned(
            left: AppDimens.mdPlus,
            top: AppDimens.mdPlus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Text(
                "FEATURED",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.6, fontSize: 12),
              ),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.md, AppDimens.lg, AppDimens.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                CategoryLocalizer.label(item.categoryLabel).toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: AppDimens.smPlus),
              Text(
                "•  ${newsTimeText(item.publishedAt)}",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
            const SizedBox(height: AppDimens.xs),
            Text(
              item.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.smPlus),
            Text(
              item.snippet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textMuted,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.mdPlus),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onReadFull,
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.bg,
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                ),
                child: const Text("Read Full Story", style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// ------------------------------------------------------------
/// Featured slider card
/// ------------------------------------------------------------
class FeaturedSliderCard extends StatelessWidget {
  const FeaturedSliderCard({super.key, required this.item, required this.onTap});

  final NewsModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = theme.cardColor;
    final border = theme.dividerColor;

    final fallbackHero = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0F1A), Color(0xFF0E2B3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: AppDimens.featuredIconSize, color: Colors.white70),
      ),
    );

    return SizedBox(
      width: AppDimens.featuredCardWidth,
      child: Material(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              border: Border.all(color: border),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: AppDimens.featuredSliderHeight,
                  width: double.infinity,
                  child: ProNetworkImage(url: item.imageUrl, fit: BoxFit.cover, placeholder: fallbackHero),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppDimens.mdPlus,
                  top: AppDimens.mdPlus,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.smPlus, vertical: AppDimens.xxs),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      item.isFeatured ? "TOP STORY" : "FEATURED",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppDimens.mdPlus,
                  right: AppDimens.mdPlus,
                  bottom: AppDimens.mdPlus,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.smPlus, vertical: AppDimens.xxs),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: isDark ? 0.9 : 0.95),
                          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Text(
                          CategoryLocalizer.label(item.categoryLabel).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.smPlus),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xxs),
                      Text(
                        newsTimeText(item.publishedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

/// ------------------------------------------------------------
/// Recent tile
/// ------------------------------------------------------------
class RecentTile extends StatelessWidget {
  const RecentTile({super.key, required this.item, required this.onTap});

  final NewsModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomePageAnimation(
      child: _RecentTileBody(item: item, onTap: onTap),
    );
  }
}

class _RecentTileBody extends StatelessWidget {
  const _RecentTileBody({required this.item, required this.onTap});

  final NewsModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final tagColor = Color(item.tagColorValue);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusLg),
              ),
              child: SizedBox(
                height: AppDimens.featuredHeroHeight,
                width: double.infinity,
                child: ProNetworkImage(url: item.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.md,
                AppDimens.md,
                AppDimens.md,
                AppDimens.mdPlus,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xsTight),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: Text(
                        CategoryLocalizer.label(item.categoryLabel),
                        style: TextStyle(color: tagColor, fontWeight: FontWeight.w800, letterSpacing: 0.4, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.xxs),
                Text(
                  item.snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textMuted,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                Divider(color: border, height: 1, thickness: 1),
                const SizedBox(height: AppDimens.sm),
                Row(
                  children: [
                    Expanded(
                      child: _MetaRow(
                        author: item.author?.trim().isEmpty ?? true ? "TAMISEMI" : item.author!.trim(),
                        date: newsDateText(item.publishedAt),
                        views: _estimateViews(item.id),
                        textColor: textMuted,
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    _ShareButton(item: item),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.item});

  final NewsModel item;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final bg = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cardDark
        : AppColors.card;
    final border = Theme.of(context).dividerColor;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        side: BorderSide(color: border),
      ),
      child: IconButton(
        onPressed: () => _share(context),
        icon: Icon(Icons.share_outlined, size: AppDimens.iconSm, color: accent),
        tooltip: 'Share',
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: const EdgeInsets.all(AppDimens.xxxs),
      ),
    );
  }

  void _share(BuildContext context) {
    final title = item.title.trim();
    final link = (item.link ?? '').trim().isNotEmpty
        ? item.link!.trim()
        : 'https://tamisemi.go.tz';
    final text = title.isEmpty ? link : '$title\n$link';
    Share.share(text, subject: title.isEmpty ? null : title);
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.author,
    required this.date,
    required this.views,
    required this.textColor,
  });

  final String author;
  final String date;
  final String views;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        );
    final dateStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        );
    return Row(
      children: [
        Expanded(
          child: _MetaChip(
            icon: Icons.person_outline,
            text: author,
            style: style,
            color: textColor,
          ),
        ),
        _MetaChip(
          icon: Icons.calendar_today_outlined,
          text: date,
          style: dateStyle,
          color: textColor,
        ),
        const SizedBox(width: AppDimens.md),
        _MetaChip(
          icon: Icons.remove_red_eye_outlined,
          text: views,
          style: style,
          color: textColor,
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    required this.style,
    required this.color,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimens.iconXs, color: accent),
        const SizedBox(width: AppDimens.xxxs),
        Flexible(
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _estimateViews(String seed) {
  var hash = 0;
  for (final code in seed.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  final count = 120 + (hash % 9880);
  if (count >= 1000) {
    final k = count / 1000.0;
    return "${k.toStringAsFixed(k >= 10 ? 0 : 1)}k";
  }
  return count.toString();
}
