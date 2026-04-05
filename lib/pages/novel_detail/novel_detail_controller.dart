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

  int? _dbNovelId;
  List<ChapterModel> _dbChapters = [];

  List<ChapterModel> get chapters {
    final list = novelDetail.value?.chapters ?? [];
    return sortAscending.value ? list : list.reversed.toList();
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
