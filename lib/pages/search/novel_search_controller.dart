import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/novel_model.dart';
import '../../services/novel_service.dart';

class NovelSearchController extends GetxController {
  final _service = Get.find<NovelService>();
  final _storage = GetStorage();
  static const _historyKey = 'searchHistory';

  var searchKeyword = ''.obs;
  var results = <NovelModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<List>(_historyKey);
    if (stored != null) {
      searchHistory.value = stored.map((e) => e.toString()).toList();
    }
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) return;
    searchKeyword.value = keyword.trim();
    _addToHistory(keyword.trim());
    isLoading.value = true;
    errorMessage.value = '';
    try {
      results.value = await _service.search(searchKeyword.value);
    } catch (e) {
      errorMessage.value = '搜尋失敗：$e';
    } finally {
      isLoading.value = false;
    }
  }

  void _addToHistory(String keyword) {
    searchHistory.remove(keyword);
    searchHistory.insert(0, keyword);
    if (searchHistory.length > 10) {
      searchHistory.removeRange(10, searchHistory.length);
    }
    _storage.write(_historyKey, searchHistory.toList());
  }

  void removeHistory(String keyword) {
    searchHistory.remove(keyword);
    _storage.write(_historyKey, searchHistory.toList());
  }

  void clearHistory() {
    searchHistory.clear();
    _storage.remove(_historyKey);
  }
}
