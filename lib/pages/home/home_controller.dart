import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/continue_reading_info.dart';
import '../../models/home_data_model.dart';
import '../../models/novel_model.dart';
import '../../services/db_helper.dart';
import '../../services/novel_service.dart';

class HomeController extends GetxController {
  final _service = Get.find<NovelService>();
  final _db = DBHelper.instance;

  var isLoading = true.obs;
  var homeData = Rxn<HomeDataModel>();
  var errorMessage = ''.obs;
  var continueReading = Rxn<ContinueReadingInfo>();

  final scrollController = ScrollController();

  List<NovelModel> get hotNovels => homeData.value?.hotNovels ?? [];
  List<NovelModel> get newNovels => homeData.value?.newNovels ?? [];

  @override
  void onReady() {
    super.onReady();
    fetchHome();
    loadContinueReading();
  }

  Future<void> fetchHome() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      homeData.value = await _service.getHome();
      await loadContinueReading();
    } catch (e) {
      errorMessage.value = '載入失敗：$e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 重新讀取「繼續閱讀」資料（純 local DB，不影響 isLoading）。
  /// Tab 切回首頁、首頁下拉刷新時呼叫。
  Future<void> loadContinueReading() async {
    try {
      continueReading.value = await _db.getContinueReading();
    } catch (_) {
      // 任何 DB 例外都不影響首頁主流程
      continueReading.value = null;
    }
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
