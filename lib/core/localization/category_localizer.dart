import 'package:get/get.dart';

class CategoryLocalizer {
  CategoryLocalizer._();

  static String label(String raw) {
    final key = _keyFor(raw);
    if (key == null) return raw;
    final translated = key.tr;
    return translated == key ? raw : translated;
  }

  static String tabLabel(String tab) {
    return label(tab);
  }

  static String? _keyFor(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return 'category.all';
    switch (value) {
      case 'all':
      case 'zote':
        return 'category.all';
      case 'education':
      case 'elimu':
        return 'category.education';
      case 'health':
      case 'afya':
        return 'category.health';
      case 'transport':
      case 'usafiri':
      case 'uchukuzi':
        return 'category.transport';
      case 'economy':
      case 'uchumi':
        return 'category.economy';
      case 'announcements':
      case 'taarifa':
      case 'update':
        return 'category.announcements';
      case 'miundombinu':
      case 'infrastructure':
        return 'category.transport';
      case 'breaking news':
      case 'breaking':
      case 'habari za dharura':
        return 'category.breaking';
      default:
        return null;
    }
  }
}
