import 'dart:async';

import '../core/models/banner_model.dart';


class BannerService {
  static const List<BannerModel> _fallbackBanners = [
    BannerModel(
      id: 'local-1',
      title: 'Welcome to GWF',
      subtitle: 'Explore digital services and latest updates.',
      imageUrl: 'https://placehold.co/900x500/png',
      isActive: true,
      priority: 2,
      link: '',
    ),
    BannerModel(
      id: 'local-2',
      title: 'Stay Informed',
      subtitle: 'Read the latest government news and announcements.',
      imageUrl: 'https://placehold.co/900x500/png?text=News',
      isActive: true,
      priority: 1,
      link: '',
    ),
  ];

  Stream<List<BannerModel>> streamActiveBanners({int limit = 10}) {
    final list = _fallbackBanners
        .where((b) => b.isActive)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return Stream.value(list.take(limit).toList());
  }
}
