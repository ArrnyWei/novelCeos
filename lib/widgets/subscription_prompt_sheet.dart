import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../pages/settings/subscription_page.dart';
import '../services/subscription_prompt_service.dart';
import '../services/subscription_service.dart';

/// 訂閱導流的 modal bottom sheet。
///
/// 兩種觸發情境：
/// - [SubscriptionPromptTrigger.launch]：每日首次冷啟
/// - [SubscriptionPromptTrigger.adDismissed]：插頁廣告被關掉第 N 次
///
/// 使用者按「查看方案」→ 不計入 dismiss count、跳到 SubscriptionPage。
/// 使用者按「稍後再說」/ 點外部關閉 → 計入 dismiss count。
enum SubscriptionPromptTrigger { launch, adDismissed }

Future<void> showSubscriptionPromptSheet(
  BuildContext context, {
  required SubscriptionPromptTrigger trigger,
}) async {
  final service = Get.find<SubscriptionPromptService>();
  service.markShownToday();

  final result = await showModalBottomSheet<_PromptResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (ctx) => _PromptSheetBody(trigger: trigger),
  );

  if (result == _PromptResult.viewPlans) {
    service.recordOpenedSubscriptionPage();
    Get.to(() => const SubscriptionPage());
  } else {
    // 點關閉、稍後、或外部 dismiss 都算被打擾
    service.recordDismissal();
  }
}

enum _PromptResult { viewPlans, dismissed }

class _PromptSheetBody extends StatelessWidget {
  final SubscriptionPromptTrigger trigger;
  const _PromptSheetBody({required this.trigger});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 有免費試用 offer 時，CTA 主打「7 天試用」鉤子；無則維持「查看方案」
    final hasTrial = Get.isRegistered<SubscriptionService>() &&
        Get.find<SubscriptionService>().hasFreeTrialOffer.value;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 48.sp,
              color: Colors.amber[700],
            ),
            SizedBox(height: 12.h),
            Text(
              hasTrial ? '先免費試 7 天，再決定要不要付' : '升級 Premium，完全去除廣告',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                const _Bullet(icon: Icons.block, text: '無橫幅 / 插頁廣告'),
                SizedBox(width: 12.w),
                const _Bullet(icon: Icons.auto_stories, text: '沉浸式閱讀'),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Get.back(result: _PromptResult.viewPlans),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  hasTrial ? '免費試 7 天' : '查看方案',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => Get.back(result: _PromptResult.dismissed),
              child: Text(
                '稍後再說',
                style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    switch (trigger) {
      case SubscriptionPromptTrigger.launch:
        return '讓今天的閱讀更安靜';
      case SubscriptionPromptTrigger.adDismissed:
        return '剛剛的廣告打擾你了嗎？';
    }
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.amber[800]),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
