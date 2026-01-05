import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';


import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/models/banner_model.dart';
import '../../../pages/news_detail.dart';



class BannerSlider extends StatefulWidget {
  final List<BannerModel> banners;
  final double height;

  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 160,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_controller.hasClients) return;
        _index = (_index + 1) % widget.banners.length;
        _controller.animateToPage(
          _index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _BannerCard(banner: widget.banners[i]),
          ),
        ),
        const SizedBox(height: AppDimens.smPlus),
        _Dots(
          count: widget.banners.length,
          activeIndex: _index,
        ),
      ],
    );
  }
}class _BannerCard extends StatelessWidget {
  final BannerModel banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
      child: GestureDetector(
        onTap: () {
          if (banner.link != null && banner.link!.isNotEmpty) {
            Get.toNamed('/web', arguments: banner.link);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProNetworkImage(
                url: banner.imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                left: AppDimens.pagePadding,
                right: AppDimens.pagePadding,
                bottom: AppDimens.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (banner.subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}class _Dots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _Dots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.xxs),
          height: AppDimens.dotSmall,
          width: i == activeIndex ? AppDimens.radiusXl : AppDimens.dotSmall,
          decoration: BoxDecoration(
            color: i == activeIndex
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
        ),
      ),
    );
  }
}
