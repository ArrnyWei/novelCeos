import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../services/reading_settings_service.dart';
import '../pages/reader/reader_controller.dart';

class ReadingSettingsOverlay extends StatelessWidget {
  final ReaderController ctrl;
  final VoidCallback onDismiss;

  const ReadingSettingsOverlay({
    super.key,
    required this.ctrl,
    required this.onDismiss,
  });

  static const _bgPresets = [
    (color: 0xFFFFFFFF, label: '白'),
    (color: 0xFFF5F5DC, label: '米'),
    (color: 0xFFD4EDDA, label: '綠'),
    (color: 0xFF2B2B2B, label: '灰'),
    (color: 0xFF1B1B1B, label: '黑'),
  ];

  static const _txtPresets = [
    (color: 0xFF000000, label: '黑'),
    (color: 0xFF333333, label: '深'),
    (color: 0xFF666666, label: '灰'),
    (color: 0xFFE0E0E0, label: '淺'),
    (color: 0xFFFFFFFF, label: '白'),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<ReadingSettingsService>();

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // Prevent dismiss when tapping panel
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Obx(() => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Chapter progress + slider
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '第 ${ctrl.currentChapterIndex.value + 1} / 共 ${ctrl.chapters.length} 章',
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                                Obx(() => Text(
                                      '${(ctrl.scrollProgress.value * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          if (ctrl.chapters.length > 1)
                            Obx(() => Slider(
                                  value: ctrl.sliderChapterIndex.value,
                                  min: 0,
                                  max: (ctrl.chapters.length - 1).toDouble(),
                                  divisions: ctrl.chapters.length - 1,
                                  label:
                                      '第 ${ctrl.sliderChapterIndex.value.round() + 1} 章',
                                  onChanged: (v) =>
                                      ctrl.sliderChapterIndex.value = v,
                                  onChangeEnd: (v) {
                                    final newIndex = v.round();
                                    if (newIndex !=
                                        ctrl.currentChapterIndex.value) {
                                      ctrl.loadChapter(newIndex);
                                    }
                                  },
                                )),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed:
                                      ctrl.hasPrev ? ctrl.prevChapter : null,
                                  icon: const Icon(Icons.chevron_left),
                                  label: const Text('上一章'),
                                ),
                              ),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed:
                                      ctrl.hasNext ? ctrl.nextChapter : null,
                                  icon: const Icon(Icons.chevron_right),
                                  label: const Text('下一章'),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 16.h),

                          // Font size
                          _SettingRow(
                            label: '字體大小',
                            trailing: Text(
                              settings.fontSize.value.toStringAsFixed(0),
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            child: Expanded(
                              child: Slider(
                                value: settings.fontSize.value,
                                min: 12,
                                max: 28,
                                divisions: 16,
                                label:
                                    settings.fontSize.value.toStringAsFixed(0),
                                onChanged: settings.setFontSize,
                              ),
                            ),
                          ),

                          // Line spacing
                          _SettingRow(
                            label: '行距',
                            trailing: Text(
                              settings.lineSpacing.value.toStringAsFixed(1),
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            child: Expanded(
                              child: Slider(
                                value: settings.lineSpacing.value,
                                min: 1.2,
                                max: 3.0,
                                divisions: 18,
                                label: settings.lineSpacing.value
                                    .toStringAsFixed(1),
                                onChanged: settings.setLineSpacing,
                              ),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Reading direction
                          _SettingRow(
                            label: '方向',
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                    value: 'vertical', label: Text('垂直')),
                                ButtonSegment(
                                    value: 'horizontal', label: Text('水平')),
                              ],
                              selected: {settings.readingDirection.value},
                              onSelectionChanged: (v) =>
                                  settings.setReadingDirection(v.first),
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Background color
                          _SettingRow(
                            label: '背景',
                            child: Row(
                              children: _bgPresets.map((p) {
                                final selected =
                                    settings.backgroundColor.value == p.color;
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: GestureDetector(
                                    onTap: () =>
                                        settings.setBackgroundColor(p.color),
                                    child: Container(
                                      width: 44.w,
                                      height: 44.w,
                                      decoration: BoxDecoration(
                                        color: Color(p.color),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant,
                                          width: selected ? 2.5 : 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Text color
                          _SettingRow(
                            label: '文字',
                            child: Row(
                              children: _txtPresets.map((p) {
                                final selected =
                                    settings.textColor.value == p.color;
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: GestureDetector(
                                    onTap: () =>
                                        settings.setTextColor(p.color),
                                    child: Container(
                                      width: 44.w,
                                      height: 44.w,
                                      decoration: BoxDecoration(
                                        color: Color(p.color),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant,
                                          width: selected ? 2.5 : 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Language
                          _SettingRow(
                            label: '語言',
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                    value: 'traditional', label: Text('繁體')),
                                ButtonSegment(
                                    value: 'simplified', label: Text('簡體')),
                              ],
                              selected: {settings.chineseVariant.value},
                              onSelectionChanged: (v) =>
                                  settings.setChineseVariant(v.first),
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),

                          SizedBox(height: 4.h),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _SettingRow({
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Text(label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
        ),
        child,
        if (trailing != null) trailing!,
      ],
    );
  }
}
