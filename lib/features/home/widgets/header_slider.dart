import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/models/banner_model.dart';

import '../../../pages/news_detail.dart';

class HeaderSlider extends StatefulWidget {
  const HeaderSlider({
    super.key,
    required this.banners,
    this.height = 170,
    this.autoPlay = true,
  });

  final List<BannerModel> banners;
  final double height;
  final bool autoPlay;

  @override
  State<HeaderSlider> createState() => _HeaderSliderState();
}

class _HeaderSliderState extends State<HeaderSlider> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HeaderSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length ||
        oldWidget.autoPlay != widget.autoPlay) {
      _setupAutoPlay();
    }
  }

  void _setupAutoPlay() {
    _timer?.cancel();
    if (!widget.autoPlay || widget.banners.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final b = widget.banners[i];
              return _BannerCard(banner: b);
            },
          ),
        ),
        const SizedBox(height: AppDimens.smPlus),
        _Dots(count: widget.banners.length, index: _index),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.smPlus),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProNetworkImage(url: banner.imageUrl, fit: BoxFit.cover),

            // dark overlay for text readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.cardPadding,
                AppDimens.cardPadding,
                AppDimens.cardPadding,
                AppDimens.cardPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                      vertical: AppDimens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Text(
                      "ANNOUNCEMENT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    banner.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xs),
                  if (banner.subtitle.trim().isNotEmpty)
                    Text(
                      banner.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.xxs),
          height: AppDimens.dotSmall,
          width: active ? AppDimens.radiusXl : AppDimens.dotSmall,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
        );
      }),
    );
  }
}
