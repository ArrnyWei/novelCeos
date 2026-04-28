import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/continue_reading_info.dart';
import '../pages/reader/reader_page.dart';
import '../services/ad_service.dart';

class ContinueReadingCard extends StatelessWidget {
  final ContinueReadingInfo info;
  const ContinueReadingCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = info.progress;
    final percentLabel =
        progress == null ? null : '${(progress * 100).toStringAsFixed(0)}%';

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (Get.isRegistered<AdService>()) {
            Get.find<AdService>().onEnterReader();
          }
          await Get.to(() => ReaderPage(
                novelUrl: info.novelUrl,
                initialChapterIndex: info.chapterIndex,
              ));
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: info.imageUrl ?? '',
                  width: 56.w,
                  height: 78.h,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 56.w,
                    height: 78.h,
                    color: scheme.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.book),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 56.w,
                    height: 78.h,
                    color: scheme.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.book),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book,
                            size: 14.sp, color: scheme.onPrimaryContainer),
                        SizedBox(width: 4.w),
                        Text(
                          '繼續閱讀',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      info.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _subtitle(percentLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                    if (progress != null) ...[
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4.h,
                          backgroundColor:
                              scheme.onPrimaryContainer.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(
                              scheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.play_arrow_rounded,
                  size: 28.sp, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(String? percentLabel) {
    if (!info.hasStarted) return '尚未閱讀 · 點此開始';
    final chapterPart = '第 ${info.chapterIndex + 1} 章';
    if (percentLabel == null) return chapterPart;
    return '$chapterPart · $percentLabel';
  }
}
