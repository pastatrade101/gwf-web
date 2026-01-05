
import 'package:flutter/foundation.dart';

@immutable
class EServiceModel {
  final String id;

  final String title;
  final String subtitle;
  final String category;
  final String ministry;

  final bool isActive;
  final bool isFeatured;
  final int priority;

  final String logoUrl; // REQUIRED
  final String? heroUrl;

  final String? overview;
  final List<String> eligibility;

  final List<Map<String, dynamic>> requiredDocuments;
  final List<Map<String, dynamic>> steps;
  final List<Map<String, dynamic>> faqs;

  final String? portalLink;
  final String? systemName;
  final String? systemOwner;

  final DateTime? updatedAt;
  final DateTime? createdAt;

  const EServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.ministry,
    required this.isActive,
    required this.isFeatured,
    required this.priority,
    required this.logoUrl,
    this.heroUrl,
    this.overview,
    this.eligibility = const [],
    this.requiredDocuments = const [],
    this.steps = const [],
    this.faqs = const [],
    this.portalLink,
    this.systemName,
    this.systemOwner,
    this.updatedAt,
    this.createdAt,
  });

  factory EServiceModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      try {
        final dyn = v as dynamic;
        final res = dyn.toDate?.call();
        if (res is DateTime) return res;
      } catch (_) {}
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    String _s(dynamic v, {String fallback = ""}) =>
        (v == null) ? fallback : v.toString().trim();

    bool _b(dynamic v, {bool fallback = false}) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == "true";
      return fallback;
    }

    int _i(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    List<String> _listStr(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    List<Map<String, dynamic>> _listMap(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return const [];
    }

    final logoUrl = _s(data["logoUrl"]);
    return EServiceModel(
      id: id,
      title: _s(data["title"], fallback: "Untitled Service"),
      subtitle: _s(data["subtitle"]),
      category: _s(data["category"], fallback: "All"),
      ministry: _s(data["ministry"]),
      isActive: _b(data["isActive"], fallback: true),
      isFeatured: _b(data["isFeatured"], fallback: false),
      priority: _i(data["priority"], fallback: 0),
      logoUrl: logoUrl,
      heroUrl: _s(data["heroUrl"]).isEmpty ? null : _s(data["heroUrl"]),
      overview: _s(data["overview"]).isEmpty ? null : _s(data["overview"]),
      eligibility: _listStr(data["eligibility"]),
      requiredDocuments: _listMap(data["requiredDocuments"]),
      steps: _listMap(data["steps"]),
      faqs: _listMap(data["faqs"]),
      portalLink: _s(data["portalLink"]).isEmpty ? null : _s(data["portalLink"]),
      systemName: _s(data["systemName"]).isEmpty ? null : _s(data["systemName"]),
      systemOwner: _s(data["systemOwner"]).isEmpty ? null : _s(data["systemOwner"]),
      updatedAt: _dt(data["updatedAt"]),
      createdAt: _dt(data["createdAt"]),
    );
  }
}