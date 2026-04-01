import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/home_data_model.dart';
import '../../models/novel_model.dart';
import '../../services/novel_service.dart';

class HomeController extends GetxController {
  final _service = Get.find<NovelService>();

  var isLoading = true.obs;
  var homeData = Rxn<HomeDataModel>();
  var errorMessage = ''.obs;

  final scrollController = ScrollController();

  List<NovelModel> get hotNovels => homeData.value?.hotNovels ?? [];
  List<NovelModel> get newNovels => homeData.value?.newNovels ?? [];

  @override
  void onReady() {
    super.onReady();
    fetchHome();
  }

  Future<void> fetchHome() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      homeData.value = await _service.getHome();
    } catch (e) {
      errorMessage.value = '載入失敗：$e';
    } finally {
      isLoading.value = false;
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
