import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/favorite_model.dart';
import '../../widgets/ad_banner_widget.dart';
import '../novel_detail/novel_detail_page.dart';
import 'library_controller.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(LibraryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('書庫'),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                icon: Icon(ctrl.viewMode.value == 'list'
                    ? Icons.grid_view
                    : Icons.list),
                onPressed: ctrl.toggleViewMode,
                tooltip: '切換檢視',
              )),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _LibraryShimmer();
        }
        if (ctrl.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('尚無收藏',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.refresh,
          child: ctrl.viewMode.value == 'list'
              ? _ListView(ctrl: ctrl)
              : _GridView(ctrl: ctrl),
        );
      }),
    );
  }
}

// ─── Shimmer skeleton ───────────────────────────────────────────────────────

class _LibraryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(8.w),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          height: 88.h,
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

// ─── List view ───────────────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  final LibraryController ctrl;
  const _ListView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: ctrl.scrollController,
      padding: EdgeInsets.all(8.w),
      itemCount: ctrl.favorites.length,
      itemBuilder: (_, i) {
        final fav = ctrl.favorites[i];
        return _ListCard(fav: fav, ctrl: ctrl);
      },
    );
  }
}

class _ListCard extends StatelessWidget {
  final FavoriteModel fav;
  final LibraryController ctrl;
  const _ListCard({required this.fav, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8.h),
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
            borderRadius: BorderRadius.circular(4.r),
            child: CachedNetworkImage(
              imageUrl: fav.imageUrl ?? '',
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
        title: Text(fav.title ?? '',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          fav.lastChapterName ?? fav.author ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.w),
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => _confirmDelete(context, fav),
        ),
        onTap: () async {
          if (fav.url != null) {
            await Get.to(() => NovelDetailPage(novelUrl: fav.url!));
            ctrl.refresh();
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, FavoriteModel fav) {
    final novelId = fav.novelId;
    final title = fav.title ?? '';
    ctrl.stageDeletion(novelId);

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('已移除「$title」'),
            action: SnackBarAction(
              label: '復原',
              onPressed: () => ctrl.undoDeletion(novelId),
            ),
            duration: const Duration(seconds: 4),
          ),
        )
        .closed
        .then((_) => ctrl.commitDeletion(novelId));
  }
}

// ─── Grid view ───────────────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  final LibraryController ctrl;
  const _GridView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: ctrl.scrollController,
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.65,
      ),
      itemCount: ctrl.favorites.length,
      itemBuilder: (_, i) {
        final fav = ctrl.favorites[i];
        return _GridCard(fav: fav, ctrl: ctrl);
      },
    );
  }
}

class _GridCard extends StatelessWidget {
  final FavoriteModel fav;
  final LibraryController ctrl;
  const _GridCard({required this.fav, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (fav.url != null) {
          await Get.to(() => NovelDetailPage(novelUrl: fav.url!));
          ctrl.refresh();
        }
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: fav.imageUrl ?? '',
                fit: BoxFit.cover,
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
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  Text(
                    fav.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    fav.author ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
