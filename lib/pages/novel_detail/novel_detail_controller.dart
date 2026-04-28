import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../models/chapter_model.dart';
import '../../models/novel_detail_model.dart';
import '../../models/novel_model.dart';
import '../../services/db_helper.dart';
import '../../services/download_service.dart';
import '../../services/novel_service.dart';

class NovelDetailController extends GetxController {
  final String novelUrl;
  NovelDetailController({required this.novelUrl});

  final _service = Get.find<NovelService>();
  final _db = DBHelper.instance;
  final downloadService = Get.find<DownloadService>();

  var isLoading = true.obs;
  var novelDetail = Rxn<NovelDetailModel>();
  var isFavorited = false.obs;
  var sortAscending = false.obs;
  var errorMessage = ''.obs;
  var downloadedListIds = <int>{}.obs;
  var lastReadChapterIndex = 0.obs;

  // 章節搜尋
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final searchTextController = TextEditingController();

  int? _dbNovelId;
  List<ChapterModel> _dbChapters = [];

  /// 章節清單（套用排序 + 搜尋過濾）。
  List<ChapterModel> get chapters {
    final all = novelDetail.value?.chapters ?? [];
    final ordered = sortAscending.value ? all : all.reversed.toList();
    final q = searchQuery.value.trim();
    if (q.isEmpty) return ordered;

    final targetNum = _extractChapterNumber(q);
    if (targetNum != null) {
      // 「第 N 章」直跳：精準比對章名中的章號數字。
      final exact =
          ordered.where((c) => _titleHasChapterNumber(c.title, targetNum)).toList();
      if (exact.isNotEmpty) return exact;
      // 找不到時退回字串模糊比對，避免使用者打數字毫無回應。
    }
    return ordered.where((c) => c.title.contains(q)).toList();
  }

  /// 給某 chapter 找出它在 detail.chapters 中的原始 index（給 ReaderPage 用）。
  int realIndexFor(ChapterModel chapter) {
    final all = novelDetail.value?.chapters ?? [];
    for (int i = 0; i < all.length; i++) {
      if (all[i].url == chapter.url) return i;
    }
    return 0;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchTextController.clear();
      searchQuery.value = '';
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  /// 從輸入抽取「第 N 章」中的 N，或純數字。回傳 null 表示不是章號查詢。
  int? _extractChapterNumber(String input) {
    final s = input.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'^\d+$').hasMatch(s)) return int.tryParse(s);
    final m = RegExp(r'^第(\d+)章?$').firstMatch(s);
    if (m != null) return int.tryParse(m.group(1)!);
    return null;
  }

  bool _titleHasChapterNumber(String title, int target) {
    final pattern = RegExp(r'第\s*(\d+)\s*章');
    for (final m in pattern.allMatches(title)) {
      if (int.tryParse(m.group(1)!) == target) return true;
    }
    return false;
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      novelDetail.value = await _service.getNovel(novelUrl);
      isFavorited.value = await _db.isNovelFavorited(novelUrl);
      final existing = await _db.getNovelByUrl(novelUrl);
      _dbNovelId = existing?.id;
      if (_dbNovelId != null) {
        _dbChapters = await _db.getChapters(_dbNovelId!);
        await _loadDownloadStatus();
        await _loadReadingProgress();
      }
    } catch (e) {
      errorMessage.value = '載入失敗：$e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns the DB list id for a chapter at the given index, or null.
  int? dbListIdForChapter(int index) {
    final detail = novelDetail.value;
    if (detail == null || _dbChapters.isEmpty) return null;
    if (index < 0 || index >= detail.chapters.length) return null;
    final url = detail.chapters[index].url;
    for (final ch in _dbChapters) {
      if (ch.url == url) return ch.id;
    }
    return null;
  }

  Future<void> _loadDownloadStatus() async {
    if (_dbNovelId == null) return;
    final ids = await _db.getDownloadedListIds(_dbNovelId!);
    downloadedListIds.clear();
    downloadedListIds.addAll(ids);
  }

  Future<void> _loadReadingProgress() async {
    if (_dbNovelId == null) return;
    final progress = await _db.getReadingProgress(_dbNovelId!);
    if (progress?.listId != null && progress!.listId! > 0) {
      // Find the chapter index by matching the listId to DB chapters
      for (int i = 0; i < _dbChapters.length; i++) {
        if (_dbChapters[i].id == progress.listId) {
          // Match by URL to get the index in the detail chapters
          final detail = novelDetail.value;
          if (detail != null) {
            for (int j = 0; j < detail.chapters.length; j++) {
              if (detail.chapters[j].url == _dbChapters[i].url) {
                lastReadChapterIndex.value = j;
                return;
              }
            }
          }
        }
      }
    }
  }

  Future<void> toggleFavorite() async {
    final detail = novelDetail.value;
    if (detail == null) return;

    _dbNovelId ??= await _db.insertNovel(
      NovelModel(
        url: novelUrl,
        imageUrl: detail.imageUrl,
        title: detail.title,
        author: detail.author,
        desc: detail.desc,
      ),
    );

    if (isFavorited.value) {
      await _db.removeFavorite(_dbNovelId!);
      isFavorited.value = false;
      Get.snackbar('已移除', '已從書架移除',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1));
    } else {
      await _db.addFavorite(_dbNovelId!);
      isFavorited.value = true;
      Get.snackbar('已收藏', '已加入書架',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1));
    }
  }

  void toggleSort() {
    sortAscending.value = !sortAscending.value;
  }

  Future<void> downloadAll() async {
    final detail = novelDetail.value;
    if (detail == null) return;
    // Fire-and-forget so the button responds immediately
    downloadService.downloadNovel(
      novelUrl: novelUrl,
      detail: detail,
    ).then((_) => _loadDownloadStatus());
  }

  /// Reload download status — call when returning from reader.
  Future<void> refreshDownloadStatus() async {
    if (_dbNovelId == null) {
      final existing = await _db.getNovelByUrl(novelUrl);
      _dbNovelId = existing?.id;
      if (_dbNovelId != null) {
        _dbChapters = await _db.getChapters(_dbNovelId!);
      }
    }
    await _loadDownloadStatus();
  }

  bool get isDownloadingThis =>
      downloadService.isDownloadingNovel(novelUrl);

  Future<int> ensureNovelInDB() async {
    final detail = novelDetail.value;
    if (detail == null) throw Exception('No detail loaded');

    _dbNovelId ??= await _db.insertNovel(
      NovelModel(
        url: novelUrl,
        imageUrl: detail.imageUrl,
        title: detail.title,
        author: detail.author,
        desc: detail.desc,
      ),
    );

    final existing = await _db.getChapters(_dbNovelId!);
    if (existing.isEmpty && detail.chapters.isNotEmpty) {
      await _db.insertChapters(_dbNovelId!, detail.chapters);
    }
    return _dbNovelId!;
  }
}
