import 'dart:async';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/e_service_model.dart';
import '../dataconnect_generated/example.dart';

class EServicesController extends GetxController {
  final searchCtrl = TextEditingController();

  final RxBool isLoading = true.obs;
  // ✅ correct
  final RxnString error = RxnString();

  final RxString activeChip = "All".obs;
  final RxString query = "".obs;

  final RxList<EServiceModel> all = <EServiceModel>[].obs;

  Timer? _debounce;
  StreamSubscription? _sub;
  QueryRef<ListServicesData, void>? _ref;

  List<String> get chips {
    // derived from data + "All"
    final set = <String>{"All"};
    for (final s in all) {
      final c = s.category.trim();
      if (c.isNotEmpty) set.add(c);
    }
    return set.toList();
  }

  @override
  void onInit() {
    super.onInit();
    _ref = ExampleConnector.instance.listServices().ref();
    _sub = _ref!.subscribe().listen((result) {
      final list = result.data.services.map(_mapService).toList();
      all.assignAll(list);
      isLoading.value = false;
      error.value = null;
    }, onError: (e) {
      isLoading.value = false;
      error.value = e.toString();
    });
  }

  void onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      query.value = v.trim();
    });
  }

  void setChip(String v) => activeChip.value = v;

  List<EServiceModel> get filtered {
    final q = query.value.toLowerCase();
    final cat = activeChip.value;

    return all.where((s) {
      final catOk = (cat == "All") || (s.category == cat);
      if (!catOk) return false;
      if (q.isEmpty) return true;

      return s.title.toLowerCase().contains(q) ||
          s.subtitle.toLowerCase().contains(q) ||
          s.ministry.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _sub?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  EServiceModel _mapService(ListServicesServices service) {
    final requirements = _splitLines(service.requirements);
    return EServiceModel(
      id: service.id,
      title: service.name,
      subtitle: service.description,
      category: "All",
      ministry: "",
      isActive: true,
      isFeatured: false,
      priority: 0,
      logoUrl: "",
      heroUrl: null,
      overview: service.description.isEmpty ? null : service.description,
      eligibility: requirements,
      requiredDocuments: const [],
      steps: const [],
      faqs: const [],
      portalLink: service.onlineLink?.trim().isEmpty == true ? null : service.onlineLink,
      systemName: null,
      systemOwner: null,
      updatedAt: null,
      createdAt: null,
    );
  }

  List<String> _splitLines(String? value) {
    if (value == null) return const [];
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    return trimmed
        .split(RegExp(r'[\n,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
