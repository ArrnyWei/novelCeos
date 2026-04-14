import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/reading_settings_service.dart';
import '../../widgets/reading_settings_overlay.dart';
import 'horizontal_reader_page.dart';
import 'reader_controller.dart';

class ReaderPage extends StatelessWidget {
  final String novelUrl;
  final int initialChapterIndex;
  const ReaderPage({
    super.key,
    required this.novelUrl,
    this.initialChapterIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      ReaderController(
        novelUrl: novelUrl,
        initialChapterIndex: initialChapterIndex,
      ),
      tag: '${novelUrl}_$initialChapterIndex',
    );
    final settings = Get.find<ReadingSettingsService>();

    return Obx(() {
      final bgColor = Color(settings.backgroundColor.value);
      final txtColor = Color(settings.textColor.value);
      final isHorizontal = settings.readingDirection.value == 'horizontal';

      if (isHorizontal) {
        return _buildHorizontalReader(context, ctrl, settings);
      }

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          toolbarHeight: 72.h,
          titleSpacing: 8.w,
          title: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ctrl.novelDetail.value?.title != null)
                    Text(
                      ctrl.novelDetail.value!.title,
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (ctrl.chapterTitle.value.isNotEmpty)
                    Text(
                      ctrl.chapterTitle.value,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600),
                    )
                  else
                    Text(
                      '載入中...',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                ],
              )),
          actions: [
            Obx(() => ctrl.isLoadingDetail.value
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () => _showChapterList(context, ctrl),
                  )),
          ],
        ),
        body: Obx(() {
          if (ctrl.isLoadingDetail.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(ctrl.errorMessage.value),
              ),
            );
          }
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ctrl.isLoadingContent.value
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            onTapUp: (details) {
                              final screenWidth =
                                  MediaQuery.of(context).size.width;
                              final x = details.globalPosition.dx;
                              if (x < screenWidth / 3) {
                                if (ctrl.hasPrev) ctrl.prevChapter();
                              } else if (x > screenWidth * 2 / 3) {
                                if (ctrl.hasNext) ctrl.nextChapter();
                              } else {
                                ctrl.showSettingsOverlay.toggle();
                              }
                            },
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Obx(() => Text(
                                    ctrl.chapterContent.value,
                                    style: TextStyle(
                                      fontSize: settings.fontSize.value,
                                      height: settings.lineSpacing.value,
                                      color: txtColor,
                                    ),
                                  )),
                            ),
                          ),
                  ),
                  _NavBar(ctrl: ctrl),
                ],
              ),
              // Settings overlay with ease-out/ease-in animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                ),
                child: ctrl.showSettingsOverlay.value
                    ? ReadingSettingsOverlay(
                        key: const ValueKey('overlay'),
                        ctrl: ctrl,
                        onDismiss: () =>
                            ctrl.showSettingsOverlay.value = false,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              // First-time onboarding hint
              if (ctrl.showOnboardingHint.value)
                _OnboardingHint(onDismiss: ctrl.dismissOnboardingHint),
            ],
          );
        }),
      );
    });
  }

  Widget _buildHorizontalReader(
      BuildContext context,
      ReaderController ctrl,
      ReadingSettingsService settings) {
    final bgColor = Color(settings.backgroundColor.value);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        toolbarHeight: 60.h,
        titleSpacing: 8.w,
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ctrl.novelDetail.value?.title != null)
                  Text(
                    ctrl.novelDetail.value!.title,
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (ctrl.chapterTitle.value.isNotEmpty)
                  Text(
                    ctrl.chapterTitle.value,
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    '載入中...',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
              ],
            )),
        actions: [
          Obx(() => ctrl.isLoadingDetail.value
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () => _showChapterList(context, ctrl),
                )),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.errorMessage.value.isNotEmpty) {
          return Center(child: Text(ctrl.errorMessage.value));
        }
        return HorizontalReaderPage(ctrl: ctrl);
      }),
    );
  }

  void _showChapterList(BuildContext context, ReaderController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => ListView.builder(
          controller: scrollCtrl,
          itemCount: ctrl.chapters.length,
          itemBuilder: (_, i) {
            return Obx(() => ListTile(
                  title: Text(ctrl.chapters[i].title),
                  selected: ctrl.currentChapterIndex.value == i,
                  onTap: () {
                    Get.back();
                    ctrl.loadChapter(i);
                  },
                ));
          },
        ),
      ),
    );
  }
}

// ─── Navigation bar ──────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final ReaderController ctrl;
  const _NavBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: ctrl.hasPrev ? ctrl.prevChapter : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('上一章'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: ctrl.hasNext ? ctrl.nextChapter : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('下一章'),
                ),
              ),
            ],
          ),
        ));
  }
}

// ─── Onboarding hint overlay ─────────────────────────────────────────────────

class _OnboardingHint extends StatelessWidget {
  final VoidCallback onDismiss;
  const _OnboardingHint({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withAlpha(180),
        child: SafeArea(
          child: Column(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    // Left zone
                    Expanded(
                      child: _HintZone(
                        icon: Icons.chevron_left,
                        label: '上一章',
                      ),
                    ),
                    // Center zone
                    Expanded(
                      child: _HintZone(
                        icon: Icons.settings,
                        label: '顯示設定',
                      ),
                    ),
                    // Right zone
                    Expanded(
                      child: _HintZone(
                        icon: Icons.chevron_right,
                        label: '下一章',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 48.h),
                child: Text(
                  '點擊任意處開始閱讀',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintZone extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HintZone({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30, width: 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
