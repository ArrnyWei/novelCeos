import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/favorite_model.dart';
import '../../services/db_helper.dart';

class LibraryController extends GetxController {
  final _db = DBHelper.instance;

  var favorites = <FavoriteModel>[].obs;
  var viewMode = 'list'.obs;
  var isLoading = false.obs;

  final scrollController = ScrollController();

  // Pending deletion state (for undo support)
  FavoriteModel? _pendingItem;
  int? _pendingDeleteId;
  int? _pendingIndex;

  @override
  void onReady() {
    super.onReady();
    refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    favorites.value = await _db.getFavorites();
    isLoading.value = false;
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

  /// Remove item from list immediately (optimistic UI). Call [commitDeletion]
  /// or [undoDeletion] after showing SnackBar.
  void stageDeletion(int novelId) {
    // Commit any existing pending deletion before staging a new one
    if (_pendingDeleteId != null) {
      _db.removeFavorite(_pendingDeleteId!);
      _pendingItem = null;
      _pendingDeleteId = null;
      _pendingIndex = null;
    }

    final index = favorites.indexWhere((f) => f.novelId == novelId);
    if (index == -1) return;
    _pendingItem = favorites[index];
    _pendingDeleteId = novelId;
    _pendingIndex = index;
    favorites.removeAt(index);
  }

  /// Called when SnackBar closes without undo — persists deletion to DB.
  Future<void> commitDeletion(int novelId) async {
    if (_pendingDeleteId == novelId) {
      await _db.removeFavorite(novelId);
      _pendingItem = null;
      _pendingDeleteId = null;
      _pendingIndex = null;
    }
  }

  /// Called when user taps Undo — restores item to list.
  void undoDeletion(int novelId) {
    if (_pendingDeleteId == novelId &&
        _pendingItem != null &&
        _pendingIndex != null) {
      favorites.insert(_pendingIndex!, _pendingItem!);
      _pendingItem = null;
      _pendingDeleteId = null;
      _pendingIndex = null;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
