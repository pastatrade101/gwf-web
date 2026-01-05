import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

/// ===============================
/// SERVICE (Map-based)
/// ===============================
class CouncilProjectService {
  static const String _base =
      "https://tausi.tamisemi.go.tz/kivuko/tausi-landsales-service/api/v1/land-open-project";

  /// IMPORTANT:
  /// - Open tab uses:  council-project
  /// - Sold tab uses:  sold-council-project  ✅ (same naming pattern as sold-council-summary)
  ///
  /// If your network tab shows a different sold endpoint name, change it here ONLY.
  Future<List<Map<String, dynamic>>> fetchCouncilProjects({
    required String administrativeAreaCode,
    required bool sold,
    int pageNo = 0,
    int pageSize = 1000,
  }) async {
    final path = sold ? "sold-council-project" : "council-project";

    final uri = Uri.parse(
      "$_base/$path?administrativeAreaCode=$administrativeAreaCode&pageNo=$pageNo&pageSize=$pageSize",
    );

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

    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

/// ===============================
/// CONTROLLER
/// ===============================
class CouncilProjectsController extends GetxController {
  CouncilProjectsController({
    required this.service,
    required this.administrativeAreaCode,
    required this.sold,
  });

  final CouncilProjectService service;
  final String administrativeAreaCode;
  final bool sold;

  final isLoading = true.obs;
  final error = RxnString();
  final items = <Map<String, dynamic>>[].obs;

  final query = "".obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = null;

      final data = await service.fetchCouncilProjects(
        administrativeAreaCode: administrativeAreaCode,
        sold: sold,
        pageNo: 0,
        pageSize: 1000,
      );

      // Sort: availablePlots desc, then reservedPlots desc, then soldPlots desc
      data.sort((a, b) {
        final avA = _toInt(a["availablePlots"]);
        final avB = _toInt(b["availablePlots"]);
        final c1 = avB.compareTo(avA);
        if (c1 != 0) return c1;

        final rA = _toInt(a["reservedPlots"]);
        final rB = _toInt(b["reservedPlots"]);
        final c2 = rB.compareTo(rA);
        if (c2 != 0) return c2;

        return _toInt(b["soldPlots"]).compareTo(_toInt(a["soldPlots"]));
      });

      items.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return items;

    return items.where((p) {
      final name = (p["projectName"] ?? "").toString().toLowerCase();
      final area = (p["administrativeAreaName"] ?? "").toString().toLowerCase();
      final code = (p["administrativeAreaCode"] ?? "").toString().toLowerCase();
      return name.contains(q) || area.contains(q) || code.contains(q);
    }).toList();
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

/// ===============================
/// PAGE: Council Projects (list)
/// ===============================
class CouncilProjectsPage extends StatelessWidget {
  const CouncilProjectsPage({
    super.key,
    required this.administrativeAreaCode,
    required this.councilName,
    required this.sold,
  });

  final String administrativeAreaCode;
  final String councilName;
  final bool sold;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final tag = "$administrativeAreaCode-${sold ? "sold" : "open"}";

    final CouncilProjectsController c = Get.put(
      CouncilProjectsController(
        service: CouncilProjectService(),
        administrativeAreaCode: administrativeAreaCode,
        sold: sold,
      ),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(councilName, style: AppTextStyles.appBar),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: text),
            onPressed: () => c.load(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.sm, AppDimens.pagePadding, 0),
          child: Column(
            children: [
              _SearchBox(
                hint: sold ? "Search sold projects..." : "Search open projects...",
                onChanged: (v) => c.query.value = v,
              ),
              const SizedBox(height: AppDimens.md),
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value) return const _LoadingList();
                  if (c.error.value != null) {
                    return _ErrorState(message: c.error.value!, onRetry: () => c.load());
                  }

                  final list = c.filtered;
                  if (list.isEmpty) {
                    return Center(child: Text("No projects found", style: AppTextStyles.bodyMuted));
                  }

                  return RefreshIndicator(
                    onRefresh: () => c.load(),
                    child: ListView.separated(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + AppDimens.lgPlus,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
                      itemBuilder: (_, i) => _ProjectCard(
                        project: list[i],
                        councilName: councilName,
                        sold: sold,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// PAGE: Project Detail
/// ===============================
class CouncilProjectDetailPage extends StatelessWidget {
  const CouncilProjectDetailPage({
    super.key,
    required this.project,
    required this.councilName,
  });

  final Map<String, dynamic> project;
  final String councilName;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _cleanHtml(String input) {
    var s = input;

    // remove tags
    s = s.replaceAll(RegExp(r'<[^>]*>'), ' ');

    // decode common entities (lightweight; no extra package)
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    final name = (project["projectName"] ?? "Project").toString();
    final areaName = (project["administrativeAreaName"] ?? councilName).toString();
    final epsg = (project["epsg"] ?? "").toString();
    final desc = (project["projectDescription"] ?? "").toString();
    final termsRaw = (project["termsAndCondition"] ?? "").toString();
    final terms = _cleanHtml(termsRaw);

    final available = _toInt(project["availablePlots"]);
    final hold = _toInt(project["holdPlots"]);
    final reserved = _toInt(project["reservedPlots"]);
    final sold = _toInt(project["soldPlots"]);

    final firstInstall = (project["firstInstallmentRate"] ?? "").toString();
    final appGrace = _toInt(project["applicationGracePeriod"]);
    final landGrace = _toInt(project["landSalesGracePeriod"]);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => Get.back(),
        ),
        title: Text("Project Details", style: AppTextStyles.appBar),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimens.pagePadding,
            AppDimens.md,
            AppDimens.pagePadding,
            MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + AppDimens.lgPlus,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Card(
                child: Row(
                  children: [
                    Container(
                      width: AppDimens.iconBoxLg,
                      height: AppDimens.iconBoxLg,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Icon(Icons.map_rounded, color: AppColors.accent),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.sectionTitle),
                          const SizedBox(height: AppDimens.xxs),
                          Text(areaName, style: AppTextStyles.bodyMuted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),

              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Plot Summary", style: AppTextStyles.sectionTitle),
                    const SizedBox(height: AppDimens.smPlus),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MiniStat(label: "Available", value: "$available"),
                        _MiniStat(label: "Reserved", value: "$reserved"),
                        _MiniStat(label: "Hold", value: "$hold"),
                        _MiniStat(label: "Sold", value: "$sold"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),

              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Parameters", style: AppTextStyles.sectionTitle),
                    const SizedBox(height: AppDimens.smPlus),
                    _KeyVal(label: "EPSG", value: epsg.isEmpty ? "—" : epsg),
                    _KeyVal(
                      label: "First installment rate",
                      value: firstInstall.isEmpty ? "—" : "$firstInstall%",
                    ),
                    _KeyVal(label: "Application grace period", value: "$appGrace days"),
                    _KeyVal(label: "Land sales grace period", value: "$landGrace days"),
                  ],
                ),
              ),

              if (desc.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimens.md),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description", style: AppTextStyles.sectionTitle),
                      const SizedBox(height: AppDimens.smPlus),
                      Text(desc, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],

              if (terms.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimens.md),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Terms & Conditions", style: AppTextStyles.sectionTitle),
                      const SizedBox(height: AppDimens.smPlus),
                      Text(terms, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// UI bits
/// ===============================
class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Container(
      height: AppDimens.fieldHeight,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: theme.dividerColor),
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

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.councilName,
    required this.sold,
  });

  final Map<String, dynamic> project;
  final String councilName;
  final bool sold;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final name = (project["projectName"] ?? "—").toString();
    final available = _toInt(project["availablePlots"]);
    final reserved = _toInt(project["reservedPlots"]);
    final soldPlots = _toInt(project["soldPlots"]);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: () {
          Get.to(() => CouncilProjectDetailPage(project: project, councilName: councilName));
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(color: theme.dividerColor),
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
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Icon(Icons.layers_rounded, color: AppColors.primary, size: AppDimens.iconMd),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: muted),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MiniStat(label: "Available", value: "$available"),
                  _MiniStat(label: "Reserved", value: "$reserved"),
                  _MiniStat(label: "Sold", value: "$soldPlots"),
                ],
              ),
              const SizedBox(height: AppDimens.xs),
              Text(
                sold ? "Sold projects list" : "Open projects list",
                style: AppTextStyles.bodyMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final card = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: border),
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

class _KeyVal extends StatelessWidget {
  const _KeyVal({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          const SizedBox(width: AppDimens.md),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
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
