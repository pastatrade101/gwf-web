import 'package:flutter/foundation.dart';

@immutable
class NewsModel {
  final String id;

  /// Must match your tab labels: All / Education / Health / Transport
  final String tabCategory;

  /// Display label e.g. "Digital Services", "Education", etc.
  final String categoryLabel;

  /// Tag like URGENT / HEALTH / EDUCATION / FEATURED
  final String tag;

  /// Store color as int for Firestore compatibility (e.g. 0xFF2F6BFF)
  final int tagColorValue;

  final String title;
  final String snippet;

  /// Optional image sources
  final String? imageUrl;
  final String? imageAsset;

  final bool isFeatured;

  /// Prefer DateTime for sorting and displaying dates
  final DateTime? publishedAt;

  /// Optional extras (future-proof for Firestore)
  final String? source;
  final String? author;
  final String? link;
  final String? region;
  final String? council;

  const NewsModel({
    required this.id,
    required this.tabCategory,
    required this.categoryLabel,
    required this.tag,
    required this.tagColorValue,
    required this.title,
    required this.snippet,
    required this.isFeatured,
    this.publishedAt,
    this.imageUrl,
    this.imageAsset,
    this.source,
    this.author,
    this.link,
    this.region,
    this.council,
  });

  /// Robust map parser (Firestore-friendly) WITHOUT importing firestore package.
  factory NewsModel.fromMap(
      Map<String, dynamic> data, {
        required String id,
      }) {
    final title = _asString(data['title']);
    final snippet = _asString(data['snippet']);

    final tabCategory = _asString(
      data['tabCategory'] ?? data['category'],
      fallback: 'All',
    );

    final categoryLabel = _asString(
      data['categoryLabel'] ?? data['categoryLabelText'] ?? data['category'],
      fallback: tabCategory,
    );

    final tag = _asString(data['tag'], fallback: 'UPDATE');

    final tagColorValue = _asInt(
      data['tagColorValue'] ?? data['tagColor'],
      fallback: 0xFF2F6BFF,
    );

    final publishedAt =
    _parseDateTime(data['publishedAt'] ?? data['createdAt'] ?? data['date']);

    // ✅ support more image keys too (optional but helpful)
    final imageUrl = _asNullableString(
      data['imageUrl'] ??
          data['coverUrl'] ??
          data['thumbnailUrl'] ??
          data['image_url'] ??
          data['cover'],
    );

    return NewsModel(
      id: id,
      tabCategory: tabCategory.isEmpty ? 'All' : tabCategory,
      categoryLabel: categoryLabel.isEmpty ? tabCategory : categoryLabel,
      tag: tag.isEmpty ? 'UPDATE' : tag,
      tagColorValue: tagColorValue,
      title: title.isEmpty ? 'Untitled News' : title,
      snippet: snippet.isEmpty ? 'No description available.' : snippet,
      isFeatured: _asBool(data['isFeatured'], fallback: false),
      publishedAt: publishedAt,
      imageUrl: imageUrl,
      imageAsset: _asNullableString(data['imageAsset']),
      source: _asNullableString(data['source']),
      author: _asNullableString(data['author']),
      link: _asNullableString(data['link']),
      region: _asNullableString(data['region']),
      council: _asNullableString(data['council']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tabCategory': tabCategory,
      'categoryLabel': categoryLabel,
      'tag': tag,
      'tagColorValue': tagColorValue,
      'title': title,
      'snippet': snippet,
      'isFeatured': isFeatured,
      'publishedAt': publishedAt, // ok for local map; Firestore will store as Timestamp if you pass Timestamp
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
      'source': source,
      'author': author,
      'link': link,
      'region': region,
      'council': council,
    };
  }

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    return title.toLowerCase().contains(q) ||
        snippet.toLowerCase().contains(q) ||
        tag.toLowerCase().contains(q) ||
        tabCategory.toLowerCase().contains(q) ||
        categoryLabel.toLowerCase().contains(q) ||
        (region?.toLowerCase().contains(q) ?? false) ||
        (council?.toLowerCase().contains(q) ?? false) ||
        (source?.toLowerCase().contains(q) ?? false) ||
        (author?.toLowerCase().contains(q) ?? false);
  }

  int compareByDateDesc(NewsModel other) {
    final a = publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final b = other.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return b.compareTo(a);
  }

  int compareByDateAsc(NewsModel other) {
    final a = publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final b = other.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return a.compareTo(b);
  }

  // ------------------ Safe Parsers ------------------

  static String _asString(dynamic v, {String fallback = ""}) {
    if (v == null) return fallback;
    if (v is String) return v.trim();
    return v.toString().trim();
  }

  static String? _asNullableString(dynamic v) {
    final s = _asString(v);
    return s.isEmpty ? null : s;
  }

  static int _asInt(dynamic v, {required int fallback}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      final cleaned = v.trim();
      if (cleaned.startsWith("0x")) {
        return int.tryParse(cleaned.substring(2), radix: 16) ?? fallback;
      }
      return int.tryParse(cleaned) ?? fallback;
    }
    return fallback;
  }

  static bool _asBool(dynamic v, {required bool fallback}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == 'yes' || s == '1') return true;
      if (s == 'false' || s == 'no' || s == '0') return false;
    }
    return fallback;
  }

  /// ✅ Robust Timestamp parsing without importing cloud_firestore.
  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;

    // Firestore Timestamp (duck-typing):
    // Timestamp has method: toDate()
    try {
      final dynamic dyn = v;
      final dynamic dt = dyn.toDate(); // call it like a method
      if (dt is DateTime) return dt;
    } catch (_) {}

    // Some people store milliseconds
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);

    // ISO string dates
    if (v is String) return DateTime.tryParse(v);

    return null;
  }
}
