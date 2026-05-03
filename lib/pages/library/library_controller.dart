import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/favorite_model.dart';
import '../../models/reading_status.dart';
import '../../services/db_helper.dart';

/// 書庫排序選項。
enum LibrarySortMode {
  lastRead('lastRead', '最近閱讀'),
  dateAdded('dateAdded', '最近加入'),
  title('title', '書名');

  final String key;
  final String label;
  const LibrarySortMode(this.key, this.label);

  static LibrarySortMode fromKey(String? key) {
    for (final m in LibrarySortMode.values) {
      if (m.key == key) return m;
    }
    return LibrarySortMode.lastRead;
  }
}

class LibraryController extends GetxController {
  final _db = DBHelper.instance;
  final _storage = GetStorage();

  static const _kSortMode = 'library.sortMode';

  /// 對外可見列表（套用 statusFilter + sortMode 後的結果）
  var favorites = <FavoriteModel>[].obs;

  /// 從 DB 抓回來的原始資料
  final _all = <FavoriteModel>[].obs;

  /// 目前狀態篩選（null = 全部）
  final Rx<ReadingStatus?> statusFilter = Rx<ReadingStatus?>(null);

  /// 目前排序方式（會持久化在 GetStorage）
  final Rx<LibrarySortMode> sortMode =
      Rx<LibrarySortMode>(LibrarySortMode.lastRead);

  var viewMode = 'list'.obs;
  var isLoading = false.obs;

  final scrollController = ScrollController();

  // Pending deletion state（undo 用）
  FavoriteModel? _pendingItem;
  int? _pendingDeleteId;
  int? _pendingIndex;

  @override
  void onInit() {
    super.onInit();
    sortMode.value = LibrarySortMode.fromKey(_storage.read<String>(_kSortMode));
    // filter 或 sort 變動 → 重新計算
    everAll([statusFilter, sortMode], (_) => _recompute());
  }

  @override
  void onReady() {
    super.onReady();
    refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    _all.value = await _db.getFavorites();
    isLoading.value = false;
    _recompute();
  }

  void setStatusFilter(ReadingStatus? s) {
    statusFilter.value = s;
  }

  void setSortMode(LibrarySortMode m) {
    sortMode.value = m;
    _storage.write(_kSortMode, m.key);
  }

  /// 變更某本書的閱讀狀態（B1 long-press 選單呼叫）
  Future<void> setStatus(int novelId, ReadingStatus s) async {
    await _db.updateFavoriteStatus(novelId, s.dbValue);
    // 不重新打 SQL，直接 patch 本地 _all 後 recompute，UI 反應更快
    final idx = _all.indexWhere((e) => e.novelId == novelId);
    if (idx != -1) {
      final old = _all[idx];
      _all[idx] = FavoriteModel(
        id: old.id,
        novelId: old.novelId,
        listId: old.listId,
        frame: old.frame,
        date: old.date,
        status: s,
        title: old.title,
        author: old.author,
        imageUrl: old.imageUrl,
        url: old.url,
        lastChapterName: old.lastChapterName,
      );
      _recompute();
    }
  }

  void _recompute() {
    var list = List<FavoriteModel>.from(_all);
    final f = statusFilter.value;
    if (f != null) {
      list = list.where((e) => e.status == f).toList();
    }
    switch (sortMode.value) {
      case LibrarySortMode.lastRead:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case LibrarySortMode.dateAdded:
        list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        break;
      case LibrarySortMode.title:
        list.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
    }
    favorites.value = list;
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'list' ? 'grid' : 'list';
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

  /// Optimistic UI delete — call [commitDeletion] or [undoDeletion] after SnackBar.
  void stageDeletion(int novelId) {
    // 若還有未 commit 的刪除，直接 commit 掉
    if (_pendingDeleteId != null) {
      _db.removeFavorite(_pendingDeleteId!);
      _pendingItem = null;
      _pendingDeleteId = null;
      _pendingIndex = null;
    }

    final index = _all.indexWhere((f) => f.novelId == novelId);
    if (index == -1) return;
    _pendingItem = _all[index];
    _pendingDeleteId = novelId;
    _pendingIndex = index;
    _all.removeAt(index);
    _recompute();
  }

  Future<void> commitDeletion(int novelId) async {
    if (_pendingDeleteId == novelId) {
      await _db.removeFavorite(novelId);
      _pendingItem = null;
      _pendingDeleteId = null;
      _pendingIndex = null;
    }
  }

  void undoDeletion(int novelId) {
    if (_pendingDeleteId == novelId &&
        _pendingItem != null &&
        _pendingIndex != null) {
      _all.insert(_pendingIndex!, _pendingItem!);
      _pendingItem = null;
      _pendingDeleteId = null;
      _pendingIndex = null;
      _recompute();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
