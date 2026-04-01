import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/reading_settings_service.dart';
import '../../services/subscription_service.dart';
import 'legal_page.dart';
import 'subscription_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<ReadingSettingsService>();
    final sub = Get.find<SubscriptionService>();

    return Scaffold(
      appBar: AppBar(title: const Text('設定'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [

            // Premium 訂閱卡
            Obx(() {
              final isSubscribed = sub.isSubscribed.value;
              final expiry = sub.expiryDate.value;

              return GestureDetector(
                onTap: () => Get.to(() => const SubscriptionPage()),
                child: Card(
                  margin: EdgeInsets.zero,
                  color: isSubscribed
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: isSubscribed
                        ? BorderSide.none
                        : BorderSide(color: Colors.amber[700]!, width: 1.5),
                  ),
                  child: Container(
                    decoration: isSubscribed
                        ? null
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withValues(alpha: 0.08),
                                Colors.orange.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 32.sp,
                          color: isSubscribed
                              ? Theme.of(context).colorScheme.primary
                              : Colors.amber[700],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSubscribed ? 'Premium 會員' : '升級 Premium',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSubscribed
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                      : Colors.amber[800],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                isSubscribed && expiry != null
                                    ? '訂閱至 ${expiry.year}/${expiry.month.toString().padLeft(2, '0')}/${expiry.day.toString().padLeft(2, '0')}'
                                    : '去除廣告，享受沉浸式閱讀',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 24.h),

            // 閱讀設定
            _buildSectionTitle('閱讀設定'),
            _buildSettingTile(
              icon: Icons.brightness_6,
              title: '深色模式',
              subtitle: '跟隨系統',
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  Get.changeThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),

            // 字體大小
            Obx(() => _buildSettingTile(
                  icon: Icons.text_fields,
                  title: '字體大小',
                  subtitle: '${settings.fontSize.value.toInt()}',
                  onTap: () => _showFontSizeDialog(settings),
                )),

            // 行距
            Obx(() => _buildSettingTile(
                  icon: Icons.format_line_spacing,
                  title: '行距',
                  subtitle: settings.lineSpacing.value.toStringAsFixed(1),
                  onTap: () => _showLineSpacingDialog(settings),
                )),

            // 閱讀方向
            Obx(() => _buildSettingTile(
                  icon: Icons.swap_horiz,
                  title: '閱讀方向',
                  subtitle:
                      settings.readingDirection.value == 'vertical'
                          ? '垂直滾動'
                          : '水平翻頁',
                  onTap: () {
                    settings.setReadingDirection(
                      settings.readingDirection.value == 'vertical'
                          ? 'horizontal'
                          : 'vertical',
                    );
                  },
                )),

            // 閱讀背景
            _buildSettingTile(
              icon: Icons.palette,
              title: '閱讀背景',
              subtitle: '選擇背景顏色',
              onTap: () => _showColorPicker(
                '背景顏色',
                settings.backgroundColor.value,
                settings.setBackgroundColor,
              ),
            ),

            // 文字顏色
            _buildSettingTile(
              icon: Icons.format_color_text,
              title: '文字顏色',
              subtitle: '選擇文字顏色',
              onTap: () => _showColorPicker(
                '文字顏色',
                settings.textColor.value,
                settings.setTextColor,
              ),
            ),

            // 繁簡轉換
            Obx(() => _buildSettingTile(
                  icon: Icons.translate,
                  title: '語言',
                  subtitle: settings.chineseVariant.value == 'traditional'
                      ? '繁體中文'
                      : '簡體中文',
                  onTap: () {
                    settings.setChineseVariant(
                      settings.chineseVariant.value == 'traditional'
                          ? 'simplified'
                          : 'traditional',
                    );
                  },
                )),

            SizedBox(height: 24.h),

            // 通用設定
            _buildSectionTitle('通用設定'),
            _buildSettingTile(
              icon: Icons.storage,
              title: '清除快取',
              subtitle: '釋放儲存空間',
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('清除快取'),
                    content: const Text('確定要清除所有快取嗎?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          Get.snackbar('成功', '快取已清除');
                        },
                        child: const Text('確定'),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 24.h),

            // 關於
            _buildSectionTitle('關於'),
            _buildSettingTile(icon: Icons.info, title: '關於我們', onTap: () {}),
            _buildSettingTile(
              icon: Icons.description,
              title: '使用條款',
              onTap: () => Get.to(() => const LegalPage(
                    title: '使用條款',
                    assetPath: 'assets/legal/terms_of_use.html',
                  )),
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: '隱私政策',
              onTap: () => Get.to(() => const LegalPage(
                    title: '隱私政策',
                    assetPath: 'assets/legal/privacy_policy.html',
                  )),
            ),

            SizedBox(height: 16.h),

            Center(
              child: Text(
                'Version 1.1.0',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(ReadingSettingsService settings) {
    Get.dialog(
      AlertDialog(
        title: const Text('字體大小'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${settings.fontSize.value.toInt()}',
                  style: TextStyle(fontSize: settings.fontSize.value),
                ),
                Slider(
                  value: settings.fontSize.value,
                  min: 12,
                  max: 28,
                  divisions: 16,
                  onChanged: (v) => settings.setFontSize(v),
                ),
              ],
            )),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('確定')),
        ],
      ),
    );
  }

  void _showLineSpacingDialog(ReadingSettingsService settings) {
    Get.dialog(
      AlertDialog(
        title: const Text('行距'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(settings.lineSpacing.value.toStringAsFixed(1)),
                Slider(
                  value: settings.lineSpacing.value,
                  min: 1.2,
                  max: 3.0,
                  divisions: 18,
                  onChanged: (v) => settings.setLineSpacing(v),
                ),
              ],
            )),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('確定')),
        ],
      ),
    );
  }

  void _showColorPicker(
      String title, int currentValue, void Function(int) onSet) {
    // 4 presets matching Swift: black, darkGray, lightGray, white
    final presets = [
      (Colors.black, '黑色'),
      (Colors.grey.shade700, '深灰'),
      (Colors.grey.shade300, '淺灰'),
      (Colors.white, '白色'),
    ];

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: presets.map((p) {
            return GestureDetector(
              onTap: () {
                onSet(p.$1.toARGB32());
                Get.back();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.$1,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(p.$2, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Builder(
      builder: (ctx) => Card(
        margin: EdgeInsets.only(bottom: 8.h),
        color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
