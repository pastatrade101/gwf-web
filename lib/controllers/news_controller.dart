import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../core/models/news_model.dart';
import '../core/constants/app_colors.dart';
import '../dataconnect_generated/example.dart';

class NewsController extends GetxController {
  NewsController({NewsService? service}) : _service = service ?? NewsService();

  final NewsService _service;

  final tabs = const ["All", "Education", "Health", "Transport"];

  final RxInt activeTab = 0.obs;
  final RxString searchQuery = "".obs;
  final RxString sortOrder = "desc".obs;
  final RxString timeRange = "all".obs;
  final RxString regionFilter = "All".obs;
  final RxString councilFilter = "All".obs;

  final RxBool loading = true.obs;
  final RxString error = "".obs;

  final RxList<NewsModel> allNews = <NewsModel>[].obs;
  final RxInt visibleCount = 10.obs;
  final int pageSize = 10;

  StreamSubscription<List<NewsModel>>? _sub;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _listenNews();
  }

  void _listenNews() {
    loading.value = true;
    error.value = "";

    _sub?.cancel();
      _sub = _service.streamPublishedNews().listen(
            (items) {
          allNews.assignAll(items);
          _resetPagination();
          loading.value = false;
          error.value = "";
        },
      onError: (e) {
        loading.value = false;
        error.value = e.toString();
      },
    );
  }

  void setTab(int index) {
    activeTab.value = index;
    _resetPagination();
  }

  void setSortOrder(String value) {
    sortOrder.value = value;
  }

  void setTimeRange(String value) {
    timeRange.value = value;
    _resetPagination();
  }

  void setRegionFilter(String value) {
    regionFilter.value = value;
    if (!councilOptions.contains(councilFilter.value)) {
      councilFilter.value = "All";
    }
    _resetPagination();
  }

  void setCouncilFilter(String value) {
    councilFilter.value = value;
    _resetPagination();
  }

  void resetFilters() {
    sortOrder.value = "desc";
    timeRange.value = "all";
    regionFilter.value = "All";
    councilFilter.value = "All";
    _resetPagination();
  }

  Future<void> refresh() async {
    try {
      error.value = "";
      final items = await _service.fetchPublishedNewsOnce(limit: 100);
      allNews.assignAll(items);
      _resetPagination();
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// ✅ Debounced search (no rebuild per letter except the list section)
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = value.trim();
      _resetPagination();
    });
  }

  String get selectedTab => tabs[activeTab.value];

  /// ✅ Filtered list (reactive)
  List<NewsModel> get filtered {
    final tab = selectedTab;
    final q = searchQuery.value;
    final range = timeRange.value;
    final region = regionFilter.value;
    final council = councilFilter.value;

    final list = allNews.where((n) {
      final matchesTab = tab == "All" || n.tabCategory == tab;
      final matchesSearch = n.matchesQuery(q);
      final matchesRange = _matchesRange(n.publishedAt, range);
      final matchesRegion = region == "All" || (n.region?.trim() == region);
      final matchesCouncil = council == "All" || (n.council?.trim() == council);
      return matchesTab && matchesSearch && matchesRange && matchesRegion && matchesCouncil;
    }).toList()
      ..sort((a, b) => _compareBySort(a, b, sortOrder.value));

    return list;
  }

  NewsModel? get featured {
    final list = filtered.where((e) => e.isFeatured).toList();
    return list.isEmpty ? null : list.first;
  }

  List<NewsModel> get featuredItems {
    final list = filtered.where((e) => e.isFeatured).toList();
    if (list.isNotEmpty) return list;
    return filtered.take(5).toList();
  }

  List<NewsModel> get featuredOnly {
    return filtered.where((e) => e.isFeatured).toList();
  }

  /// ✅ You said: recent updates should include featured too
  List<NewsModel> get recent => List<NewsModel>.from(filtered);
  List<NewsModel> get visibleRecent => recent.take(visibleCount.value).toList();
  bool get hasMore => visibleCount.value < recent.length;

  List<String> get regionOptions {
    final set = <String>{};
    for (final item in allNews) {
      final r = item.region?.trim();
      if (r != null && r.isNotEmpty) set.add(r);
    }
    final list = set.toList()..sort();
    return ["All", ...list];
  }

  List<String> get councilOptions {
    final region = regionFilter.value;
    final set = <String>{};
    for (final item in allNews) {
      final r = item.region?.trim();
      final c = item.council?.trim();
      if (c == null || c.isEmpty) continue;
      if (region == "All" || r == region) {
        set.add(c);
      }
    }
    final list = set.toList()..sort();
    return ["All", ...list];
  }

  void loadMore() {
    if (hasMore) {
      visibleCount.value =
          (visibleCount.value + pageSize).clamp(0, recent.length);
    }
  }

  String get timeRangeLabelKey {
    switch (timeRange.value) {
      case "7d":
        return "last_7_days";
      case "30d":
        return "last_30_days";
      default:
        return "all_time";
    }
  }

  String get sortLabelKey => sortOrder.value == "asc" ? "oldest" : "newest";

  @override
  void onClose() {
    _debounce?.cancel();
    _sub?.cancel();
    super.onClose();
  }

  void _resetPagination() {
    visibleCount.value = pageSize;
  }

  bool _matchesRange(DateTime? dt, String range) {
    if (range == "all") return true;
    if (dt == null) return false;
    final now = DateTime.now();
    final days = range == "7d" ? 7 : 30;
    return now.difference(dt).inDays <= days;
  }

  int _compareBySort(NewsModel a, NewsModel b, String order) {
    if (order == "asc") {
      return a.compareByDateAsc(b);
    }
    return a.compareByDateDesc(b);
  }
}


class NewsService {
  Stream<List<NewsModel>> streamPublishedNews({int limit = 100}) {
    final ref = ExampleConnector.instance.listNewsArticles().ref();
    return ref.subscribe().map((result) {
      final list = result.data.newsArticles.map(_mapArticle).toList()
        ..sort((a, b) => a.compareByDateDesc(b));
      return limit > 0 && list.length > limit ? list.sublist(0, limit) : list;
    });
  }

  Stream<List<NewsModel>> streamAllNews({int limit = 200}) {
    return streamPublishedNews(limit: limit);
  }

  Future<List<NewsModel>> fetchPublishedNewsOnce({int limit = 50}) async {
    final result = await ExampleConnector.instance.listNewsArticles().execute();
    final list = result.data.newsArticles.map(_mapArticle).toList()
      ..sort((a, b) => a.compareByDateDesc(b));
    return limit > 0 && list.length > limit ? list.sublist(0, limit) : list;
  }

  NewsModel _mapArticle(ListNewsArticlesNewsArticles article) {
    final category = article.category.trim();
    final normalizedTab = _tabCategoryFor(category);
    final title = article.title.trim();
    final content = article.content.trim();
    final tag = category.isEmpty ? "ANNOUNCEMENTS" : category.toUpperCase();
    final snippet = _compactSnippet(content);
    final tagColorValue = _tagColorValue(tag);
    return NewsModel(
      id: article.id,
      tabCategory: normalizedTab,
      categoryLabel: category.isEmpty ? "All" : category,
      tag: tag,
      tagColorValue: tagColorValue,
      title: title.isEmpty ? 'Untitled News' : title,
      snippet: snippet,
      isFeatured: false,
      publishedAt: _toDateTime(article.publishedAt),
      imageUrl: article.imageUrl,
      imageAsset: null,
      source: null,
      author: (article.author ?? '').trim().isEmpty ? null : article.author!.trim(),
      link: null,
      region: (article.region ?? '').trim().isEmpty ? null : article.region!.trim(),
      council: (article.council ?? '').trim().isEmpty ? null : article.council!.trim(),
    );
  }

  String _compactSnippet(String content) {
    final text = content.trim();
    if (text.length <= 160) return text;
    return '${text.substring(0, 157).trim()}...';
  }

  int _tagColorValue(String tag) {
    switch (tag.toLowerCase()) {
      case 'breaking news':
      case 'breaking':
        return AppColors.breakingNews.value;
      case 'health':
        return AppColors.health.value;
      case 'education':
      case 'elimu':
        return AppColors.education.value;
      case 'economy':
      case 'uchumi':
        return AppColors.economy.value;
      case 'announcements':
      case 'taarifa':
      case 'update':
        return AppColors.announcements.value;
      default:
        return AppColors.secondary.value;
    }
  }

  String _tabCategoryFor(String category) {
    if (category.trim().isEmpty) return "All";
    switch (category.trim().toLowerCase()) {
      case 'education':
      case 'elimu':
        return 'Education';
      case 'health':
      case 'afya':
        return 'Health';
      case 'transport':
      case 'usafiri':
      case 'uchukuzi':
        return 'Transport';
      default:
        return 'All';
    }
  }

  DateTime? _toDateTime(Timestamp ts) {
    try {
      return ts.toDateTime();
    } catch (_) {
      return DateTime.tryParse(ts.toString());
    }
  }

}
