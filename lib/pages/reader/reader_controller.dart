import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/chapter_model.dart';
import '../../models/novel_detail_model.dart';
import '../../models/novel_model.dart';
import '../../services/ad_service.dart';
import '../../services/db_helper.dart';
import '../../services/novel_service.dart';
import '../../services/reading_settings_service.dart';
import '../../utils/chinese_converter.dart';

class ReaderController extends GetxController {
  final String novelUrl;
  final int initialChapterIndex;
  ReaderController({required this.novelUrl, this.initialChapterIndex = 0});

  final _service = Get.find<NovelService>();
  final _db = DBHelper.instance;
  final _settings = Get.find<ReadingSettingsService>();

  var isLoadingDetail = true.obs;
  var isLoadingContent = false.obs;
  var novelDetail = Rxn<NovelDetailModel>();
  var currentChapterIndex = 0.obs;
  var chapterTitle = ''.obs;
  var chapterContent = ''.obs;
  var errorMessage = ''.obs;
  var showSettingsOverlay = false.obs;
  var showOnboardingHint = false.obs;

  Map<String, int> _chapterIdMap = {};

  List<ChapterModel> get chapters => novelDetail.value?.chapters ?? [];

  @override
  void onReady() {
    super.onReady();
    if (GetStorage().read<bool>('hasSeenReaderHint') != true) {
      showOnboardingHint.value = true;
    }
    _loadDetail();
  }

  void dismissOnboardingHint() {
    showOnboardingHint.value = false;
    GetStorage().write('hasSeenReaderHint', true);
  }

  Future<void> _loadDetail() async {
    isLoadingDetail.value = true;
    errorMessage.value = '';
    try {
      novelDetail.value = await _service.getNovel(novelUrl);
      await _ensureChaptersInDB();
      if (chapters.isNotEmpty) {
        await loadChapter(initialChapterIndex.clamp(0, chapters.length - 1));
      }
    } catch (e) {
      errorMessage.value = '載入失敗：$e';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> _ensureChaptersInDB() async {
    final detail = novelDetail.value;
    if (detail == null) return;
    try {
      final novelId = await _db.insertNovel(
        NovelModel(
          url: novelUrl,
          imageUrl: detail.imageUrl,
          title: detail.title,
          author: detail.author,
          desc: detail.desc,
        ),
      );
      var dbChapters = await _db.getChapters(novelId);
      if (dbChapters.isEmpty && detail.chapters.isNotEmpty) {
        await _db.insertChapters(novelId, detail.chapters);
        dbChapters = await _db.getChapters(novelId);
      }
      _chapterIdMap = {for (final ch in dbChapters) ch.url: ch.id!};
    } catch (_) {
      // Non-critical — reading still works without DB
    }
  }

  Future<void> loadChapter(int index) async {
    if (index < 0 || index >= chapters.length) return;
    isLoadingContent.value = true;
    errorMessage.value = '';
    try {
      final chapter = chapters[index];
      String content = '';
      String title = chapter.title;

      // Try offline content first
      final listId = _chapterIdMap[chapter.url];
      if (listId != null) {
        final offline = await _db.getOfflineContent(listId);
        if (offline != null) {
          content = offline;
        }
      }

      // Fallback to network
      if (content.isEmpty) {
        final result = await _service.getContent(chapter.url);
        content = result.content;
        if (result.title.isNotEmpty) title = result.title;
        // Auto-save to DB for offline access
        if (listId != null && content.isNotEmpty) {
          await _db.insertContent(listId, result.content);
        }
      }

      // Apply Chinese conversion
      if (_settings.chineseVariant.value == 'simplified') {
        content = ChineseConverter.toSimplified(content);
        title = ChineseConverter.toSimplified(title);
      }

      currentChapterIndex.value = index;
      chapterTitle.value = title;
      chapterContent.value = content;
    } catch (e) {
      errorMessage.value = '載入章節失敗：$e';
    } finally {
      isLoadingContent.value = false;
    }
  }

  void nextChapter() {
    if (Get.isRegistered<AdService>()) Get.find<AdService>().onChapterChanged();
    loadChapter(currentChapterIndex.value + 1);
  }

  void prevChapter() {
    if (Get.isRegistered<AdService>()) Get.find<AdService>().onChapterChanged();
    loadChapter(currentChapterIndex.value - 1);
  }

  bool get hasPrev => currentChapterIndex.value > 0;
  bool get hasNext => currentChapterIndex.value < chapters.length - 1;
}
