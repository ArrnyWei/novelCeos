import 'package:get/get.dart';

import '../models/novel_detail_model.dart';
import '../models/novel_model.dart';
import 'db_helper.dart';
import 'novel_service.dart';

/// Manages offline downloads — translates NovelViewController's download logic.
class DownloadService extends GetxController {
  final _service = Get.find<NovelService>();
  final _db = DBHelper.instance;

  var isDownloading = false.obs;
  var progress = 0.0.obs;
  var downloadingNovelUrl = ''.obs;
  bool _cancelRequested = false;

  /// Downloads all chapters of a novel for offline reading.
  Future<void> downloadNovel({
    required String novelUrl,
    required NovelDetailModel detail,
  }) async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadingNovelUrl.value = novelUrl;
    progress.value = 0.0;
    _cancelRequested = false;

    try {
      // Ensure novel + chapters in DB
      final novelId = await _db.insertNovel(
        NovelModel(
          url: novelUrl,
          imageUrl: detail.imageUrl,
          title: detail.title,
          author: detail.author,
          desc: detail.desc,
        ),
      );

      final existingChapters = await _db.getChapters(novelId);
      if (existingChapters.isEmpty && detail.chapters.isNotEmpty) {
        await _db.insertChapters(novelId, detail.chapters);
      }

      // Reload chapters from DB to get IDs
      final chapters = await _db.getChapters(novelId);
      final total = chapters.length;

      for (int i = 0; i < total; i++) {
        if (_cancelRequested) break;
        final ch = chapters[i];

        // Skip if already downloaded
        final existing = await _db.getOfflineContent(ch.id!);
        if (existing != null) {
          progress.value = (i + 1) / total;
          continue;
        }

        try {
          final result = await _service.getContent(ch.url);
          await _db.insertContent(ch.id!, result.content);
        } catch (_) {
          // Skip failed chapters, continue with rest
        }

        progress.value = (i + 1) / total;
      }

      if (_cancelRequested) {
        Get.snackbar('下載已取消', '${detail.title} 下載已取消',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('下載完成', '${detail.title} 已下載完成',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('下載失敗', '$e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDownloading.value = false;
      downloadingNovelUrl.value = '';
      progress.value = 0.0;
    }
  }

  void cancelDownload() {
    _cancelRequested = true;
  }

  bool isDownloadingNovel(String novelUrl) =>
      isDownloading.value && downloadingNovelUrl.value == novelUrl;
}
