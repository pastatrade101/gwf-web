import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import 'e_service_detail_page.dart';


class EServicesPage extends StatelessWidget {
  EServicesPage({super.key});

  final EServicesController c = Get.put(EServicesController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final isDark = theme.brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final card = theme.cardColor;
    final border = theme.dividerColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Government E-Services",
          style: AppTextStyles.appBar,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: text),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.sm,
                AppDimens.pagePadding,
                AppDimens.md,
              ),
              child: _SearchBar(
                onChanged: c.onSearchChanged,
                hint: "Search for a service...",
              ),
            ),

            // Category chips
            SizedBox(
              height: AppDimens.chipRowHeight,
              child: Obx(() {
                final cats = c.categories;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppDimens.md),
                  itemBuilder: (_, i) {
                    final label = cats[i];
                    final selected = c.activeCategory.value == label;

                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : text,
                      ),
                      selectedColor: AppColors.secondary,
                      backgroundColor: card,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: selected ? Colors.transparent : border,
                        ),
                      ),
                      onSelected: (_) => c.activeCategory.value = label,
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: AppDimens.smPlus),

            // Info banner
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 0, AppDimens.pagePadding, AppDimens.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.accent, size: AppDimens.iconSm),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Text(
                        "Information only. No login required.",
                        style: AppTextStyles.bodyMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const _LoadingList();
                }

                if (c.error.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.xxl),
                      child: Text(
                        "Failed to load services:\n${c.error.value}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }

                final list = c.filtered;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.xxl),
                      child: Text(
                        "No services found.",
                        style: AppTextStyles.bodyMuted,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePadding,
                    AppDimens.xs,
                    AppDimens.pagePadding,
                    AppDimens.lg,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
                  itemBuilder: (_, i) => _ServiceCard(
                    item: list[i],
                    onTap: () => Get.to(() => EServiceDetailPage(service: list[i])),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- Controller ----------------------------- */

class EServicesController extends GetxController {
  // state
  final isLoading = true.obs;
  final RxnString error = RxnString();

  final all = <EServiceModel>[].obs;

  // filters
  final activeCategory = "All".obs;
  final query = "".obs;

  late final Worker _debouncer;

  List<String> get categories {
    final set = <String>{"All"};
    for (final s in all) {
      if (s.category.trim().isNotEmpty) set.add(s.category.trim());
    }
    return set.toList();
  }

  List<EServiceModel> get filtered {
    final q = query.value.trim().toLowerCase();
    final cat = activeCategory.value;

    final list = all.where((s) {
      final catOk = (cat == "All") || s.category == cat;
      final qOk = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.subtitle.toLowerCase().contains(q) ||
          s.ministry.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
      return catOk && qOk;
    }).toList();

    list.sort((a, b) => b.priority.compareTo(a.priority));
    return list;
  }

  @override
  void onInit() {
    super.onInit();

    // debounce search updates (prevents rebuild spam while typing)
    _debouncer = debounce<String>(
      query,
      (_) {}, // we only store query; UI reads filtered reactively
      time: const Duration(milliseconds: 350),
    );

    all.assignAll(_seedServices());
    isLoading.value = false;
    error.value = null;
  }

  void onSearchChanged(String v) {
    query.value = v.trim();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  List<EServiceModel> _seedServices() {
    return [
      EServiceModel(
        id: "cmk0rcsv1001myo23iscl0r89",
        title: "TAUSI",
        subtitle:
            "Portal that facilitates taxpayer access to services offered by Local Government Authorities (LGAs).",
        category: "Payments",
        ministry: "TAMISEMI / PO-RALG",
        logoUrl: "assets/logos/icon.png",
        heroUrl: "assets/logos/icon.png",
        portalUrl: "https://tausi.tamisemi.go.tz",
        isActive: true,
        priority: 1,
        updatedAt: null,
        overview:
            "TAUSI provides a single access point for taxpayers to reach LGA services and payments.",
        eligibility: const ["Citizens", "Businesses", "Revenue officers"],
        requiredDocs: const [
          DocItem(title: "Taxpayer details", type: "Account", icon: ""),
          DocItem(title: "Payment method", type: "Payment", icon: ""),
        ],
        processSteps: const [
          StepItem(title: "Open the portal", description: "Visit the TAUSI portal."),
          StepItem(title: "Select service", description: "Choose the required service."),
          StepItem(title: "Pay and confirm", description: "Complete payment and receive confirmation."),
        ],
        faqs: const [],
        etaMinutes: 7,
      ),
      EServiceModel(
        id: "cmk0qzrrg0000yo23qu0w5rp9",
        title: "SIS",
        subtitle: "Education management services for Tanzania schools.",
        category: "Education",
        ministry: "TAMISEMI / PO-RALG",
        logoUrl: "assets/logos/PNG LOGO.png",
        heroUrl: "assets/logos/PNG LOGO.png",
        portalUrl: "https://sis.tamisemi.go.tz/logi",
        isActive: true,
        priority: 1,
        updatedAt: null,
        overview: "SIS provides a comprehensive suite of services for education management in schools.",
        eligibility: const ["School administrators", "Education officers"],
        requiredDocs: const [
          DocItem(title: "School ID", type: "ID", icon: ""),
          DocItem(title: "Official account", type: "Account", icon: ""),
        ],
        processSteps: const [
          StepItem(title: "Sign in", description: "Use official school credentials."),
          StepItem(title: "Update records", description: "Manage student and staff information."),
          StepItem(title: "Submit reports", description: "Send reports to authorities."),
        ],
        faqs: const [],
        etaMinutes: 9,
      ),
      EServiceModel(
        id: "cmk0rknn1002iyo235lnqbs4u",
        title: "GOTHOMIS",
        subtitle:
            "Integrated platform with modules to manage healthcare operations efficiently.",
        category: "Health",
        ministry: "TAMISEMI / MOH",
        logoUrl: "assets/logos/gothomis logo.png",
        heroUrl: "assets/logos/gothomis logo.png",
        portalUrl: "https://gothomis.tamisemi.go.tz",
        isActive: true,
        priority: 3,
        updatedAt: null,
        overview:
            "GoTHOMIS supports healthcare providers and administrators with operational tools and reporting.",
        eligibility: const ["Facility managers", "Health staff"],
        requiredDocs: const [
          DocItem(title: "Facility ID", type: "ID", icon: ""),
          DocItem(title: "Official account", type: "Account", icon: ""),
        ],
        processSteps: const [
          StepItem(title: "Sign in", description: "Use facility credentials."),
          StepItem(title: "Manage modules", description: "Access the required health modules."),
          StepItem(title: "Report", description: "Submit official health reports."),
        ],
        faqs: const [],
        etaMinutes: 12,
      ),
      EServiceModel(
        id: "cmk0rf3yh0022yo238np4g996",
        title: "MMAMA",
        subtitle: "Emergency response and transport for maternal care.",
        category: "Health",
        ministry: "TAMISEMI / MOH",
        logoUrl: "assets/logos/M-MAMA_Linear_Tanzania_RGB.jpg",
        heroUrl: "assets/logos/M-MAMA_Linear_Tanzania_RGB.jpg",
        portalUrl: "https://mama.moh.go.tz/",
        isActive: true,
        priority: 3,
        updatedAt: null,
        overview: "MMAMA coordinates emergency response for mothers and newborns.",
        eligibility: const ["Health facilities", "Emergency dispatch teams"],
        requiredDocs: const [
          DocItem(title: "Facility registration", type: "ID", icon: ""),
        ],
        processSteps: const [
          StepItem(title: "Register", description: "Register your facility or dispatch unit."),
          StepItem(title: "Request transport", description: "Submit emergency request details."),
          StepItem(title: "Confirm dispatch", description: "Track ambulance assignment."),
        ],
        faqs: const [],
        etaMinutes: 5,
      ),
      EServiceModel(
        id: "cmk0rrkap002yyo230koc4jz7",
        title: "Plan Rep",
        subtitle: "Planning and reporting system for councils.",
        category: "Local Government",
        ministry: "TAMISEMI / PO-RALG",
        logoUrl: "assets/logos/planrep.png",
        heroUrl: "assets/logos/planrep.png",
        portalUrl: "https://planrep.tamisemi.go.tz",
        isActive: true,
        priority: 5,
        updatedAt: null,
        overview: "PLANREP supports planning, budgeting, and reporting in LGAs.",
        eligibility: const ["Council planning officers", "Budget teams"],
        requiredDocs: const [
          DocItem(title: "Official ID", type: "ID", icon: ""),
          DocItem(title: "Work Email", type: "Account", icon: ""),
        ],
        processSteps: const [
          StepItem(title: "Access the portal", description: "Visit the PLANREP portal."),
          StepItem(title: "Select council", description: "Choose the LGA you manage."),
          StepItem(title: "Submit plan", description: "Enter and submit planning data."),
        ],
        faqs: const [],
        etaMinutes: 10,
      ),
    ];
  }
}

/* ----------------------------- Model ----------------------------- */

class EServiceModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String ministry;

  final String logoUrl; // small icon
  final String heroUrl; // optional banner/hero image

  final String portalUrl;
  final bool isActive;
  final int priority;

  final DateTime? updatedAt;

  // detail fields
  final String overview;
  final List<String> eligibility;
  final List<DocItem> requiredDocs;
  final List<StepItem> processSteps;
  final List<FaqItem> faqs;

  final int etaMinutes;

  const EServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.ministry,
    required this.logoUrl,
    required this.heroUrl,
    required this.portalUrl,
    required this.isActive,
    required this.priority,
    required this.updatedAt,
    required this.overview,
    required this.eligibility,
    required this.requiredDocs,
    required this.processSteps,
    required this.faqs,
    required this.etaMinutes,
  });

  factory EServiceModel.fromMap(Map<String, dynamic> data, {required String id}) {
    String s(dynamic v, {String fallback = ""}) {
      if (v == null) return fallback;
      if (v is String) return v.trim();
      return v.toString().trim();
    }

    int i(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    bool b(dynamic v, {bool fallback = false}) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final x = v.toLowerCase().trim();
        if (x == "true" || x == "1" || x == "yes") return true;
        if (x == "false" || x == "0" || x == "no") return false;
      }
      return fallback;
    }

    DateTime? dt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      try {
        final dynamic dyn = v;
        final d = dyn.toDate?.call();
        if (d is DateTime) return d;
      } catch (_) {}
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    List<String> listStr(dynamic v) {
      if (v is List) {
        return v.map((e) => s(e)).where((x) => x.isNotEmpty).toList();
      }
      return const [];
    }

    List<DocItem> listDocs(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((m) => DocItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
      return const [];
    }

    List<StepItem> listSteps(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((m) => StepItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
      return const [];
    }

    List<FaqItem> listFaq(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((m) => FaqItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
      return const [];
    }

    return EServiceModel(
      id: id,
      title: s(data["title"], fallback: "Untitled Service"),
      subtitle: s(data["subtitle"], fallback: ""),
      category: s(data["category"], fallback: "All"),
      ministry: s(data["ministry"], fallback: ""),
      logoUrl: s(data["logoUrl"] ?? data["logo"] ?? data["imageUrl"], fallback: ""),
      heroUrl: s(data["heroUrl"] ?? data["bannerUrl"], fallback: ""),
      portalUrl: s(data["portalUrl"] ?? data["link"], fallback: ""),
      isActive: b(data["isActive"], fallback: true),
      priority: i(data["priority"], fallback: 0),
      updatedAt: dt(data["updatedAt"] ?? data["createdAt"]),
      overview: s(data["overview"], fallback: s(data["description"], fallback: "")),
      eligibility: listStr(data["eligibility"]),
      requiredDocs: listDocs(data["requiredDocs"]),
      processSteps: listSteps(data["processSteps"]),
      faqs: listFaq(data["faqs"]),
      etaMinutes: i(data["etaMinutes"], fallback: 10),
    );
  }
}

class DocItem {
  final String title;
  final String type; // e.g. PDF, JPG
  final String icon; // optional future use

  const DocItem({required this.title, required this.type, required this.icon});

  factory DocItem.fromMap(Map<String, dynamic> m) {
    final t = (m["title"] ?? "").toString().trim();
    final ty = (m["type"] ?? "").toString().trim();
    final ic = (m["icon"] ?? "").toString().trim();
    return DocItem(title: t, type: ty, icon: ic);
  }
}

class StepItem {
  final String title;
  final String description;

  const StepItem({required this.title, required this.description});

  factory StepItem.fromMap(Map<String, dynamic> m) {
    return StepItem(
      title: (m["title"] ?? "").toString().trim(),
      description: (m["description"] ?? "").toString().trim(),
    );
  }
}

class FaqItem {
  final String q;
  final String a;

  const FaqItem({required this.q, required this.a});

  factory FaqItem.fromMap(Map<String, dynamic> m) {
    return FaqItem(
      q: (m["q"] ?? m["question"] ?? "").toString().trim(),
      a: (m["a"] ?? m["answer"] ?? "").toString().trim(),
    );
  }
}

/* ----------------------------- Widgets ----------------------------- */

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged, required this.hint});

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Container(
      height: AppDimens.fieldHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: muted),
          prefixIcon: Icon(Icons.search_rounded, color: muted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.md,
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.onTap});

  final EServiceModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              _NetImage(
                url: item.logoUrl,
                size: AppDimens.logoSizeSm,
                radius: AppDimens.radiusMd,
                fallbackIcon: Icons.apps_rounded,
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.sectionTitle,
                          ),
                        ),
                        const SizedBox(width: AppDimens.xs),
                        Icon(Icons.verified_rounded, size: AppDimens.iconXs, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xxs),
                    Text(
                      item.ministry.isEmpty ? "TAMISEMI / PO-RALG" : item.ministry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted.copyWith(color: muted),
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      item.subtitle.isEmpty ? "Official government e-service." : item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted.copyWith(color: muted),
                    ),
                    const SizedBox(height: AppDimens.smPlus),
                    Row(
                      children: [
                        _Tag(item.category),
                        const Spacer(),
                        Text("View Details", style: AppTextStyles.link.copyWith(color: text)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: theme.brightness == Brightness.dark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: AppColors.accent,
        ),
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
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePadding,
        AppDimens.xs,
        AppDimens.pagePadding,
        AppDimens.lg,
      ),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
      itemBuilder: (_, __) => Container(
        height: AppDimens.loadingCardHeightLg,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          border: Border.all(color: theme.dividerColor),
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage({
    required this.url,
    required this.size,
    required this.radius,
    required this.fallbackIcon,
  });

  final String url;
  final double size;
  final double radius;
  final IconData fallbackIcon;

  bool get _has => url.trim().isNotEmpty;
  bool get _isAsset => url.trim().startsWith("assets/");

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
      ),
      child: Icon(fallbackIcon, color: AppColors.accent),
    );

    if (!_has) return fallback;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppDimens.xs),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: _isAsset
            ? Image.asset(
                url.trim(),
                fit: BoxFit.contain,
              )
            : Image.network(
                url.trim(),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
