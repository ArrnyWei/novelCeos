import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/ad_service.dart';
import '../reader/reader_page.dart';
import 'novel_detail_controller.dart';

class NovelDetailPage extends StatelessWidget {
  final String novelUrl;
  const NovelDetailPage({super.key, required this.novelUrl});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      NovelDetailController(novelUrl: novelUrl),
      tag: novelUrl,
    );

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (!ctrl.isSearching.value) return const Text('小說詳情');
          return TextField(
            controller: ctrl.searchTextController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: ctrl.onSearchChanged,
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: '搜尋章節 / 第 N 章',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          );
        }),
        actions: [
          Obx(() => IconButton(
                tooltip: ctrl.isSearching.value ? '關閉搜尋' : '搜尋章節',
                icon: Icon(ctrl.isSearching.value ? Icons.close : Icons.search),
                onPressed: ctrl.toggleSearch,
              )),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ctrl.errorMessage.value),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () {
                      ctrl.errorMessage.value = '';
                      ctrl.onReady();
                    },
                    child: const Text('重試'),
                  ),
                ],
              ),
            ),
          );
        }
        final detail = ctrl.novelDetail.value!;
        return Column(
          children: [
            // Header
            _Header(ctrl: ctrl, detail: detail),
            const Divider(height: 1),
            // Chapter list header — count 反映搜尋過濾後筆數
            Obx(() => _ChapterListHeader(
                  ctrl: ctrl,
                  count: ctrl.chapters.length,
                  total: detail.chapters.length,
                )),
            // Chapter list
            Expanded(
              child: Obx(() {
                final chapters = ctrl.chapters;
                if (chapters.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        '找不到符合「${ctrl.searchQuery.value}」的章節',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: chapters.length,
                  itemBuilder: (_, i) {
                    final chapter = chapters[i];
                    final realIndex = ctrl.realIndexFor(chapter);
                    final listId = ctrl.dbListIdForChapter(realIndex);
                    return ListTile(
                      dense: true,
                      title: Text(
                        chapters[i].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      trailing: listId != null &&
                              ctrl.downloadedListIds.contains(listId)
                          ? Icon(Icons.download_done,
                              size: 16.sp, color: Colors.green)
                          : null,
                      onTap: () async {
                        Get.find<AdService>().onEnterReader();
                        await Get.to(() => ReaderPage(
                              novelUrl: novelUrl,
                              initialChapterIndex: realIndex,
                            ));
                        ctrl.refreshDownloadStatus();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final NovelDetailController ctrl;
  final dynamic detail;
  const _Header({required this.ctrl, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: detail.imageUrl,
              width: 100.w,
              height: 140.h,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 100.w,
                height: 140.h,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.book, size: 40),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 100.w,
                height: 140.h,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.book, size: 40),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(detail.author,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                SizedBox(height: 4.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: detail.state.contains('完結')
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    detail.state.isEmpty ? '連載中' : detail.state,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  detail.desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 12.h),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => ctrl.isFavorited.value
                          ? OutlinedButton.icon(
                              onPressed: ctrl.toggleFavorite,
                              icon: Icon(Icons.bookmark,
                                  size: 16.sp,
                                  color: Theme.of(context).colorScheme.primary),
                              label: const FittedBox(child: Text('移除書架')),
                            )
                          : FilledButton.icon(
                              onPressed: ctrl.toggleFavorite,
                              icon: Icon(Icons.bookmark_border, size: 16.sp),
                              label: const FittedBox(child: Text('加入書架')),
                            )),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                            onPressed: () async {
                              Get.find<AdService>().onEnterReader();
                              await Get.to(() => ReaderPage(
                                    novelUrl: ctrl.novelUrl,
                                    initialChapterIndex:
                                        ctrl.lastReadChapterIndex.value,
                                  ));
                              ctrl.refreshDownloadStatus();
                            },
                            icon: Icon(Icons.play_arrow, size: 16.sp),
                            label: FittedBox(
                              child: Text(ctrl.lastReadChapterIndex.value > 0
                                  ? '繼續閱讀'
                                  : '開始閱讀'),
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Download button
                Obx(() {
                  final ds = ctrl.downloadService;
                  if (ds.isDownloadingNovel(ctrl.novelUrl)) {
                    return Column(
                      children: [
                        LinearProgressIndicator(
                            value: ds.progress.value),
                        SizedBox(height: 4.h),
                        Text(
                          '下載中 ${(ds.progress.value * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        TextButton(
                          onPressed: ds.cancelDownload,
                          child: const Text('取消下載',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  }
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: ctrl.downloadAll,
                      icon: const Icon(Icons.download),
                      label: const Text('下載全部'),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterListHeader extends StatelessWidget {
  final NovelDetailController ctrl;
  final int count;
  final int total;
  const _ChapterListHeader({
    required this.ctrl,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isFiltered = count != total;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            isFiltered ? '章節列表 ($count / $total)' : '章節列表 ($total)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Obx(() => TextButton.icon(
                onPressed: ctrl.toggleSort,
                icon: Icon(
                  ctrl.sortAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16.sp,
                ),
                label: Text(ctrl.sortAscending.value ? '正序' : '倒序'),
              )),
        ],
      ),
    );
  }
}
