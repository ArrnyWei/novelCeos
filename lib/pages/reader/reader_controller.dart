import 'dart:async';

import 'package:flutter/widgets.dart';
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
  var scrollProgress = 0.0.obs;
  var sliderChapterIndex = 0.0.obs;

  Map<String, int> _chapterIdMap = {};
  int? _dbNovelId;

  final ScrollController scrollController = ScrollController();
  Timer? _scrollDebounce;
  int? _savedListId;
  double _savedOffset = 0.0;

  /// In-memory preload cache keyed by chapter index → (title, content).
  final Map<int, (String, String)> _preloadCache = {};

  List<ChapterModel> get chapters => novelDetail.value?.chapters ?? [];

  @override
  void onReady() {
    super.onReady();
    scrollController.addListener(_onScroll);
    if (GetStorage().read<bool>('hasSeenReaderHint') != true) {
      showOnboardingHint.value = true;
    }
    _loadDetail();
  }

  @override
  void onClose() {
    _scrollDebounce?.cancel();
    _saveProgress();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.maxScrollExtent > 0) {
      scrollProgress.value = (scrollController.offset /
              scrollController.position.maxScrollExtent)
          .clamp(0.0, 1.0);
    }
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 200), _saveProgress);
  }

  Future<void> _saveProgress() async {
    if (_dbNovelId == null) return;
    final listId = _currentListId;
    if (listId == null) return;
    final offset = scrollController.hasClients ? scrollController.offset : 0.0;
    await _db.updateReadingProgress(
      novelId: _dbNovelId!,
      listId: listId,
      frame: offset,
    );
  }

  int? get _currentListId {
    final idx = currentChapterIndex.value;
    if (idx < 0 || idx >= chapters.length) return null;
    return _chapterIdMap[chapters[idx].url];
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
      if (_dbNovelId != null) {
        final progress = await _db.getReadingProgress(_dbNovelId!);
        if (progress != null &&
            progress.listId != null &&
            progress.listId! > 0) {
          _savedListId = progress.listId;
          _savedOffset = progress.frame;
        }
      }
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
      _dbNovelId = await _db.insertNovel(
        NovelModel(
          url: novelUrl,
          imageUrl: detail.imageUrl,
          title: detail.title,
          author: detail.author,
          desc: detail.desc,
        ),
      );
      var dbChapters = await _db.getChapters(_dbNovelId!);
      if (dbChapters.isEmpty && detail.chapters.isNotEmpty) {
        await _db.insertChapters(_dbNovelId!, detail.chapters);
        dbChapters = await _db.getChapters(_dbNovelId!);
      }
      _chapterIdMap = {for (final ch in dbChapters) ch.url: ch.id!};
    } catch (_) {}
  }

  Future<void> loadChapter(int index) async {
    if (index < 0 || index >= chapters.length) return;
    isLoadingContent.value = true;
    errorMessage.value = '';
    scrollProgress.value = 0.0;
    try {
      String title;
      String content;

      final cached = _preloadCache.remove(index);
      if (cached != null) {
        title = cached.$1;
        content = cached.$2;
      } else {
        (title, content) = await _fetchChapter(index);
      }

      currentChapterIndex.value = index;
      sliderChapterIndex.value = index.toDouble();
      chapterTitle.value = title;
      chapterContent.value = content;
      isLoadingContent.value = false;

      _schedulePreloadNext(index);
      _restoreOrResetScroll();
      _saveProgress();
    } catch (e) {
      errorMessage.value = '載入章節失敗：$e';
      isLoadingContent.value = false;
    }
  }

  void _restoreOrResetScroll() {
    final listId = _currentListId;
    final shouldRestore =
        _savedListId != null && listId == _savedListId && _savedOffset > 0;

    if (shouldRestore) {
      final offset = _savedOffset;
      _savedListId = null;
      _savedOffset = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          final max = scrollController.position.maxScrollExtent;
          scrollController.jumpTo(offset.clamp(0.0, max));
        }
      });
    } else {
      _savedListId = null;
      _savedOffset = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients && scrollController.offset != 0) {
          scrollController.jumpTo(0);
        }
      });
    }
  }

  /// Fetch a chapter (offline first, network fallback) and apply variant conversion.
  Future<(String, String)> _fetchChapter(int index) async {
    final chapter = chapters[index];
    String content = '';
    String title = chapter.title;

    final listId = _chapterIdMap[chapter.url];
    if (listId != null) {
      final offline = await _db.getOfflineContent(listId);
      if (offline != null) content = offline;
    }

    if (content.isEmpty) {
      final result = await _service.getContent(chapter.url);
      content = result.content;
      if (result.title.isNotEmpty) title = result.title;
      if (listId != null && content.isNotEmpty) {
        await _db.insertContent(listId, result.content);
      }
    }

    if (_settings.chineseVariant.value == 'simplified') {
      content = ChineseConverter.toSimplified(content);
      title = ChineseConverter.toSimplified(title);
    }
    return (title, content);
  }

  /// Fire-and-forget preload of the next chapter into memory.
  void _schedulePreloadNext(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= chapters.length) return;
    if (_preloadCache.containsKey(nextIndex)) return;
    Future<void>(() async {
      try {
        final result = await _fetchChapter(nextIndex);
        _preloadCache[nextIndex] = result;
      } catch (_) {}
    });
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
