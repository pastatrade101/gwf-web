import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import 'council_landsale_detail_page.dart';

/// ===============================
/// MODEL (lightweight)
/// ===============================
class CouncilSummaryItem {
  final String administrativeAreaName;
  final String administrativeAreaCode;
  final int totalProjects;
  final int totalPlots;
  final DateTime? lastProjectCreatedAt;

  CouncilSummaryItem({
    required this.administrativeAreaName,
    required this.administrativeAreaCode,
    required this.totalProjects,
    required this.totalPlots,
    required this.lastProjectCreatedAt,
  });

  factory CouncilSummaryItem.fromMap(Map<String, dynamic> m) {
    DateTime? dt;
    final raw = (m['lastProjectCreatedAt'] ?? '').toString().trim();
    if (raw.isNotEmpty) dt = DateTime.tryParse(raw);

    return CouncilSummaryItem(
      administrativeAreaName: (m['administrativeAreaName'] ?? '').toString(),
      administrativeAreaCode: (m['administrativeAreaCode'] ?? '').toString(),
      totalProjects: _toInt(m['totalProjects']),
      totalPlots: _toInt(m['totalPlots']),
      lastProjectCreatedAt: dt,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

/// ===============================
/// SERVICE
/// ===============================
class LandSaleService {
  static const String _base =
      "https://tausi.tamisemi.go.tz/kivuko/tausi-landsales-service/api/v1/land-open-project";

  Future<List<CouncilSummaryItem>> fetchCouncilSummary({
    required bool sold,
    int pageNo = 0,
    int pageSize = 1000,
  }) async {
    final path = sold ? "sold-council-summary" : "council-summary";
    final uri = Uri.parse("$_base/$path?pageNo=$pageNo&pageSize=$pageSize");

    final res = await http.get(
      uri,
      headers: const {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Origin": "https://tausi.tamisemi.go.tz",
        "Referer": "https://tausi.tamisemi.go.tz/",
        "User-Agent":
        "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final Map<String, dynamic> root = jsonDecode(res.body);
    final status = (root["status"] ?? "").toString().toLowerCase();
    if (status != "true") throw Exception(root["description"] ?? "Request failed");

    final data = (root["data"] as Map?) ?? {};
    final list = (data["itemList"] as List?) ?? const [];

    return list
        .whereType<Map>()
        .map((e) => CouncilSummaryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// ===============================
/// CONTROLLER (GetX)
/// ===============================
class LandSaleController extends GetxController {
  final LandSaleService _service;
  LandSaleController(this._service);

  final isLoadingOpen = true.obs;
  final isLoadingSold = true.obs;

  final openError = RxnString();
  final soldError = RxnString();

  final openItems = <CouncilSummaryItem>[].obs;
  final soldItems = <CouncilSummaryItem>[].obs;

  final query = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadOpen(), loadSold()]);
  }

  Future<void> loadOpen() async {
    try {
      isLoadingOpen.value = true;
      openError.value = null;

      final data = await _service.fetchCouncilSummary(sold: false, pageNo: 0, pageSize: 1000);
      data.sort((a, b) {
        final c1 = b.totalProjects.compareTo(a.totalProjects);
        if (c1 != 0) return c1;
        return b.totalPlots.compareTo(a.totalPlots);
      });

      openItems.assignAll(data);
    } catch (e) {
      openError.value = e.toString();
    } finally {
      isLoadingOpen.value = false;
    }
  }

  Future<void> loadSold() async {
    try {
      isLoadingSold.value = true;
      soldError.value = null;

      final data = await _service.fetchCouncilSummary(sold: true, pageNo: 0, pageSize: 1000);
      data.sort((a, b) {
        final c1 = b.totalProjects.compareTo(a.totalProjects);
        if (c1 != 0) return c1;
        return b.totalPlots.compareTo(a.totalPlots);
      });

      soldItems.assignAll(data);
    } catch (e) {
      soldError.value = e.toString();
    } finally {
      isLoadingSold.value = false;
    }
  }

  List<CouncilSummaryItem> filter(List<CouncilSummaryItem> src) {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return src;
    return src.where((x) {
      return x.administrativeAreaName.toLowerCase().contains(q) ||
          x.administrativeAreaCode.toLowerCase().contains(q);
    }).toList();
  }
}

/// ===============================
/// PAGE (Tabs: Open / Sold)
/// ===============================
class LandSalePage extends StatelessWidget {
  LandSalePage({super.key});

  final LandSaleController c = Get.put(LandSaleController(LandSaleService()));

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: Text("Land Sales", style: AppTextStyles.appBar),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: text),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: text),
              onPressed: () => c.loadAll(),
            ),
          ],
          bottom: TabBar(
            labelColor: text,
            unselectedLabelColor: muted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900),
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Open Land"),
              Tab(text: "Sold Land"),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.sm, AppDimens.pagePadding, 0),
            child: Column(
              children: [
                _SearchBox(
                  hint: "Search council (name or code)...",
                  onChanged: (v) => c.query.value = v,
                ),
                const SizedBox(height: AppDimens.md),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CouncilTab(
                        sold: false,
                        isLoading: c.isLoadingOpen,
                        error: c.openError,
                        list: c.openItems,
                        onRefresh: () => c.loadOpen(),
                        filter: c.filter,
                      ),
                      _CouncilTab(
                        sold: true,
                        isLoading: c.isLoadingSold,
                        error: c.soldError,
                        list: c.soldItems,
                        onRefresh: () => c.loadSold(),
                        filter: c.filter,
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

class _CouncilTab extends StatelessWidget {
  const _CouncilTab({
    required this.sold,
    required this.isLoading,
    required this.error,
    required this.list,
    required this.onRefresh,
    required this.filter,
  });

  final bool sold;
  final RxBool isLoading;
  final RxnString error;
  final RxList<CouncilSummaryItem> list;
  final Future<void> Function() onRefresh;
  final List<CouncilSummaryItem> Function(List<CouncilSummaryItem>) filter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) return const _LoadingList();

      if (error.value != null) {
        return _ErrorState(
          message: error.value!,
          onRetry: () => onRefresh(),
        );
      }

      final filtered = filter(list);
      if (filtered.isEmpty) {
        return Center(child: Text("No results", style: AppTextStyles.bodyMuted));
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + AppDimens.lgPlus,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
          itemBuilder: (_, i) => _CouncilCard(item: filtered[i], sold: sold),
        ),
      );
    });
  }
}

/// ===============================
/// UI WIDGETS
/// ===============================
class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      height: AppDimens.fieldHeight,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: border),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMuted.copyWith(color: muted),
          prefixIcon: Icon(Icons.search_rounded, color: muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.lg,
          ),
        ),
      ),
    );
  }
}

class _CouncilCard extends StatelessWidget {
  const _CouncilCard({required this.item, required this.sold});
  final CouncilSummaryItem item;
  final bool sold;

  String _dateText(DateTime? dt) {
    if (dt == null) return "—";
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, "0");
    final d = dt.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final muted = theme.brightness == Brightness.dark
        ? AppColors.textMutedDark
        : AppColors.textMuted;
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: () {
          // ✅ IMPORTANT: pass sold flag so projects page calls sold endpoint too
          Get.to(() => CouncilProjectsPage(
            administrativeAreaCode: item.administrativeAreaCode,
            councilName: item.administrativeAreaName,
            sold: sold,
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppDimens.iconBoxMd,
                    height: AppDimens.iconBoxMd,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Icon(Icons.account_balance_rounded, color: AppColors.accent, size: AppDimens.iconLg),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text(
                      item.administrativeAreaName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.xs),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 110),
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      item.administrativeAreaCode,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

              // ✅ FIX OVERFLOW: use Wrap instead of Row
                Wrap(
                spacing: AppDimens.md,
                runSpacing: AppDimens.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _StatChip(label: "Projects", value: item.totalProjects.toString()),
                  _StatChip(label: "Plots", value: item.totalPlots.toString()),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, size: AppDimens.iconSm, color: muted),
                      const SizedBox(width: AppDimens.xs),
                      Text(_dateText(item.lastProjectCreatedAt), style: AppTextStyles.bodyMuted),
                      const SizedBox(width: AppDimens.xs),
                      Icon(Icons.chevron_right_rounded, color: muted),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
          const SizedBox(width: AppDimens.xs),
          Text(label, style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + AppDimens.lgPlus,
      ),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
      itemBuilder: (_, __) => Container(
        height: AppDimens.loadingCardHeight,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          border: Border.all(color: theme.dividerColor),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        margin: const EdgeInsets.only(top: AppDimens.xxl),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Failed to load", style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppDimens.xs),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppDimens.md),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
