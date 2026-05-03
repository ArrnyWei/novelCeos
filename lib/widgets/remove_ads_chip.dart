import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../pages/settings/subscription_page.dart';

/// 黏在 banner 廣告正上方的薄條 chip。
/// 「升級 Premium 移除廣告」CTA。點擊 → SubscriptionPage。
///
/// 由 [AdBannerWidget] 負責 visibility — 廣告沒顯示就不會渲染這個 chip。
class RemoveAdsChip extends StatelessWidget {
  const RemoveAdsChip({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.amber.withValues(alpha: 0.12),
      child: InkWell(
        onTap: () => Get.to(() => const SubscriptionPage()),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Icons.workspace_premium,
                  size: 14.sp, color: Colors.amber[800]),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '升級 Premium 移除廣告',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 16.sp, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
