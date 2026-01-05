class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isActive;
  final int priority;
  final String? link;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isActive,
    required this.priority,
    this.link,
  });

  /// ✅ ID is positional, not named
  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      priority: map['priority'] ?? 0,
      link: map['link'],
    );
  }
}