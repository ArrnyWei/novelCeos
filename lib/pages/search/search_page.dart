import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/ad_banner_widget.dart';
import '../novel_detail/novel_detail_page.dart';
import 'novel_search_controller.dart';

class SearchPage extends StatelessWidget {
  final String initialKeyword;
  const SearchPage({super.key, required this.initialKeyword});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(NovelSearchController());
    final textCtrl = TextEditingController(text: initialKeyword);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialKeyword.isNotEmpty) ctrl.search(initialKeyword);
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: textCtrl,
          autofocus: initialKeyword.isEmpty,
          decoration: const InputDecoration(
            hintText: '搜尋小說、作者...',
            border: InputBorder.none,
          ),
          onSubmitted: (v) => ctrl.search(v),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => ctrl.search(textCtrl.text),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.errorMessage.value.isNotEmpty) {
          return Center(child: Text(ctrl.errorMessage.value));
        }
        // Show history when no search submitted yet
        if (ctrl.searchKeyword.value.isEmpty) {
          return _SearchHistory(ctrl: ctrl, textCtrl: textCtrl);
        }
        if (ctrl.results.isEmpty) {
          return const Center(child: Text('無搜尋結果'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(8.w),
          itemCount: ctrl.results.length,
          itemBuilder: (_, i) {
            final novel = ctrl.results[i];
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                minVerticalPadding: 0,
                leading: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: novel.imageUrl,
                      width: 45.w,
                      height: 65.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 45.w,
                        height: 65.h,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.book, size: 24),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 45.w,
                        height: 65.h,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.book, size: 24),
                      ),
                    ),
                  ),
                ),
                title: Text(novel.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${novel.author}\n${novel.desc}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp),
                ),
                isThreeLine: true,
                onTap: () =>
                    Get.to(() => NovelDetailPage(novelUrl: novel.url)),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Search history ───────────────────────────────────────────────────────────

class _SearchHistory extends StatelessWidget {
  final NovelSearchController ctrl;
  final TextEditingController textCtrl;
  const _SearchHistory({required this.ctrl, required this.textCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.searchHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text('輸入關鍵字搜尋小說',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近搜尋',
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: ctrl.clearHistory,
                child: Text('清除', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: ctrl.searchHistory.map((keyword) {
              return InputChip(
                label: Text(keyword, style: TextStyle(fontSize: 13.sp)),
                onPressed: () {
                  textCtrl.text = keyword;
                  ctrl.search(keyword);
                },
                onDeleted: () => ctrl.removeHistory(keyword),
                deleteIconColor: Colors.grey,
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
