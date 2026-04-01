import 'package:get/get.dart';

import '../../models/novel_model.dart';
import '../../services/novel_service.dart';

class CategoryController extends GetxController {
  final String categoryName;
  final String categoryId;
  CategoryController({required this.categoryName, required this.categoryId});

  static const typeUrlDic = {
    '玄幻奇幻': '1',
    '武俠仙俠': '2',
    '現代都市': '3',
    '歷史軍事': '4',
    '科幻小說': '5',
    '遊戲競技': '6',
    '恐怖靈異': '7',
    '言情小說': '8',
    '動漫同人': '9',
    '其他類型': '10',
  };

  final _service = Get.find<NovelService>();

  var novels = <NovelModel>[].obs;
  var currentPage = 1.obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var errorMessage = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadCategory();
  }

  Future<void> loadCategory() async {
    isLoading.value = true;
    errorMessage.value = '';
    currentPage.value = 1;
    try {
      novels.value = await _service.getList(categoryId, 1);
      hasMore.value = novels.isNotEmpty;
    } catch (e) {
      errorMessage.value = '載入失敗：$e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final next = currentPage.value + 1;
      final more = await _service.getList(categoryId, next);
      if (more.isEmpty) {
        hasMore.value = false;
      } else {
        currentPage.value = next;
        novels.addAll(more);
      }
    } catch (_) {
      // Silently fail for load-more
    } finally {
      isLoadingMore.value = false;
    }
  }
}
