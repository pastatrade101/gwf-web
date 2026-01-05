import 'dart:async';
import 'package:get/get.dart';

import '../../core/models/banner_model.dart';
import '../../services/banner_service.dart';



class HomeController extends GetxController {
  final BannerService _bannerService = BannerService();

  // UI state
  final searchText = "".obs;
  final currentBanner = 0.obs;

  // Data
  final banners = <BannerModel>[].obs;
  final isBannerLoading = true.obs;
  final bannerError = RxnString();

  StreamSubscription? _bannerSub;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _bindBanners();
  }

  void _bindBanners() {
    isBannerLoading.value = true;
    bannerError.value = null;

    _bannerSub?.cancel();
    _bannerSub = _bannerService.streamActiveBanners(limit: 10).listen(
          (data) {
        banners.assignAll(data);
        isBannerLoading.value = false;
      },
      onError: (e) {
        bannerError.value = e.toString();
        isBannerLoading.value = false;
      },
    );
  }

  void onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchText.value = v.trim();
    });
  }

  void setBannerIndex(int i) => currentBanner.value = i;

  @override
  void onClose() {
    _debounce?.cancel();
    _bannerSub?.cancel();
    super.onClose();
  }
}