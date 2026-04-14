import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/novel_model.dart';
import '../../widgets/ad_banner_widget.dart';
import '../category/category_controller.dart';
import '../category/category_page.dart';
import '../novel_detail/novel_detail_page.dart';
import '../search/search_page.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('首頁'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => controller.isLoading.value
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.fetchHome,
                  tooltip: '重新整理',
                )),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _HomeShimmer();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage.value),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: controller.fetchHome,
                    child: const Text('重試'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchHome,
            child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SearchBar(),
                SizedBox(height: 20.h),
                Text(
                  '小說分類',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                const _CategoryGrid(),
                SizedBox(height: 24.h),
                Text(
                  '熱門推薦',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                _HotNovelList(novels: controller.hotNovels),
                SizedBox(height: 24.h),
                Text(
                  '最新更新',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                _NewNovelList(novels: controller.newNovels),
              ],
            ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Shimmer skeleton ───────────────────────────────────────────────────────

class _HomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar skeleton
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 20.h),
            // Category grid skeleton
            _shimmerBox(80.w, 18.h, 4.r),
            SizedBox(height: 12.h),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 2.8,
              children: List.generate(
                6,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Hot novels skeleton
            _shimmerBox(80.w, 18.h, 4.r),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (_, __) => Container(
                  width: 120.w,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // New novels skeleton
            _shimmerBox(80.w, 18.h, 4.r),
            SizedBox(height: 16.h),
            ...List.generate(
              4,
              (_) => Container(
                height: 88.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Search bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜尋小說、作者...',
          border: InputBorder.none,
          icon: const Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onSubmitted: (keyword) {
          if (keyword.trim().isEmpty) return;
          Get.to(() => SearchPage(initialKeyword: keyword.trim()));
        },
      ),
    );
  }
}

// ─── Category grid ───────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final categories = CategoryController.typeUrlDic.entries.toList();
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: 2.8,
      children: categories.map((e) {
        return OutlinedButton(
          onPressed: () => Get.to(() => CategoryPage(
                categoryName: e.key,
                categoryId: e.value,
              )),
          child: Text(
            e.key,
            style: TextStyle(fontSize: 12.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Hot novels ──────────────────────────────────────────────────────────────

class _HotNovelList extends StatelessWidget {
  final List<NovelModel> novels;
  const _HotNovelList({required this.novels});

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: const Center(child: Text('暫無資料')),
      );
    }
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: novels.length,
        itemBuilder: (context, index) {
          final novel = novels[index];
          return GestureDetector(
            onTap: () => Get.to(() => NovelDetailPage(novelUrl: novel.url)),
            child: Container(
              width: 120.w,
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: novel.imageUrl,
                        fit: BoxFit.cover,
                        width: 120.w,
                        placeholder: (_, __) => Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.book, size: 40),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.book, size: 40),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    novel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    novel.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── New novels ──────────────────────────────────────────────────────────────

class _NewNovelList extends StatelessWidget {
  final List<NovelModel> novels;
  const _NewNovelList({required this.novels});

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) {
      return const Center(child: Text('暫無資料'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: novels.length,
      itemBuilder: (context, index) {
        final novel = novels[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12.h),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
            minVerticalPadding: 0,
            leading: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: novel.imageUrl,
                  width: 50.w,
                  height: 70.h,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 50.w,
                    height: 70.h,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const Icon(Icons.book),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 50.w,
                    height: 70.h,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const Icon(Icons.book),
                  ),
                ),
              ),
            ),
            title: Text(
              novel.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${novel.author} • ${novel.desc}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
            onTap: () => Get.to(() => NovelDetailPage(novelUrl: novel.url)),
          ),
        );
      },
    );
  }
}
