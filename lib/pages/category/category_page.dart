import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/ad_banner_widget.dart';
import '../novel_detail/novel_detail_page.dart';
import 'category_controller.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;
  final String categoryId;
  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      CategoryController(categoryName: categoryName, categoryId: categoryId),
      tag: categoryId,
    );

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      bottomNavigationBar: const AdBannerWidget(),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ctrl.errorMessage.value),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: ctrl.loadCategory,
                  child: const Text('重試'),
                ),
              ],
            ),
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >
                notification.metrics.maxScrollExtent - 200) {
              ctrl.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.all(8.w),
            itemCount: ctrl.novels.length + (ctrl.hasMore.value ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= ctrl.novels.length) {
                return Padding(
                  padding: EdgeInsets.all(16.h),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final novel = ctrl.novels[i];
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
          ),
        );
      }),
    );
  }
}
