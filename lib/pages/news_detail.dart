import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/models/news_model.dart';
import '../core/localization/category_localizer.dart';

class ProShimmer extends StatefulWidget {
  final Widget child;
  final double radius;

  const ProShimmer({super.key, required this.child, this.radius = AppDimens.radiusLg});

  @override
  State<ProShimmer> createState() => _ProShimmerState();
}

class _ProShimmerState extends State<ProShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
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
      borderRadius: BorderRadius.circular(widget.radius),
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


class ProNetworkImage extends StatelessWidget {
  final String? url;
  final double radius;
  final BoxFit fit;

  /// ✅ add placeholder support
  final Widget? placeholder;

  const ProNetworkImage({
    super.key,
    required this.url,
    this.radius = AppDimens.radiusLg,
    this.fit = BoxFit.cover,
    this.placeholder, // ✅ new
  });

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fallbackBg = theme.cardColor;
    final iconColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final shimmerBase = theme.dividerColor;
    final fallback = placeholder ??
        Container(
          color: fallbackBg,
          child: Center(
            child: Icon(Icons.image_outlined, color: iconColor),
          ),
        );

    if (!_hasUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: fallback,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url!.trim(),
        fit: fit,
        loadingBuilder: (context, child, prog) {
          if (prog == null) return child;
          return ProShimmer(
            radius: radius,
            child: Container(color: shimmerBase),
          );
        },
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class NewsDetailPagePro extends StatelessWidget {
  final NewsModel news;

  const NewsDetailPagePro({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final tagColor = Color(news.tagColorValue);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            stretch: true,
            expandedHeight: 280,
            automaticallyImplyLeading: true,
            leading: _GlassIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _GlassIconButton(
                icon: Icons.share_rounded,
                onTap: () {
                  // add share later if you want
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Share coming soon")),
                  );
                },
              ),
              const SizedBox(width: AppDimens.smPlus),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image
                  ProNetworkImage(
                    url: news.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B0F1A), Color(0xFF0E2B3D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.newspaper_rounded,
                          color: Colors.white70,
                          size: AppDimens.newsHeroIcon,
                        ),
                      ),
                    ),
                  ),
                  // Dark gradient overlay for text legibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Bottom meta (title + chips)
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _Pill(
                              text: CategoryLocalizer.label(news.categoryLabel),
                              bg: Colors.white.withValues(alpha: 0.14),
                              fg: Colors.white,
                              border: Colors.white.withValues(alpha: 0.22),
                            ),
                            _Pill(
                              text: CategoryLocalizer.label(news.tag),
                              bg: tagColor.withValues(alpha: 0.18),
                              fg: tagColor,
                              border: tagColor.withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.md),
                        Text(
                          news.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          _dateText(news.publishedAt),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
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

          // Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.md, AppDimens.pagePadding, AppDimens.lg),
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                AppDimens.lg,
              ),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((news.snippet).trim().isNotEmpty) ...[
                    Text(
                      news.snippet,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.mdPlus),
                    Divider(color: border),
                    const SizedBox(height: AppDimens.mdPlus),
                  ],

                  // If you have a full content field later, use it here.
                  // For now we show a "body" built from snippet + optional link/source.
                  Text(
                    _buildBody(news),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: AppDimens.lgPlus),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (news.source != null && news.source!.trim().isNotEmpty)
                        _MetaChip(icon: Icons.apartment_rounded, text: news.source!),
                      if (news.author != null && news.author!.trim().isNotEmpty)
                        _MetaChip(icon: Icons.person_rounded, text: news.author!),
                      if (news.link != null && news.link!.trim().isNotEmpty)
                        _MetaChip(icon: Icons.link_rounded, text: "Open link"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppDimens.lgPlus)),
        ],
      ),
    );
  }

  static String _buildBody(NewsModel n) {
    // If later you add `content` field in model, replace this.
    // For now, show a clean readable body.
    final b = StringBuffer();
    b.writeln(n.snippet.trim());
    b.writeln();
    b.writeln(
        "This update is provided under ${CategoryLocalizer.label(n.categoryLabel)}. Please check official sources for any new changes.");
    if (n.link != null && n.link!.trim().isNotEmpty) {
      b.writeln();
      b.writeln("More info: ${n.link}");
    }
    return b.toString().trim();
  }

  static String _dateText(DateTime? dt) {
    if (dt == null) return "—";
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return "${dt.year}-$mm-$dd";
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          onTap: onTap,
          child: Ink(
            width: AppDimens.iconButtonSize,
            height: AppDimens.iconButtonSize,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.25),
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color border;

  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final iconColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.md),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimens.iconSm, color: iconColor),
          const SizedBox(width: AppDimens.xs),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}
