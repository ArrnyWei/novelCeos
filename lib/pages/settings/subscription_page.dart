import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/subscription_service.dart';
import 'legal_page.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = Get.find<SubscriptionService>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium 會員')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // ── Header ──
              Icon(Icons.workspace_premium,
                  size: 64.sp, color: Colors.amber[700]),
              SizedBox(height: 12.h),
              Text(
                '升級 Premium',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '享受最佳閱讀體驗',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: cs.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 32.h),

              // ── Benefits ──
              _BenefitTile(
                icon: Icons.block,
                title: '完全無廣告',
                subtitle: '移除所有橫幅與插頁廣告',
                cs: cs,
              ),
              _BenefitTile(
                icon: Icons.auto_stories,
                title: '沉浸式閱讀',
                subtitle: '不受干擾的純粹閱讀體驗',
                cs: cs,
              ),
              _BenefitTile(
                icon: Icons.support_agent,
                title: '優先支援',
                subtitle: '會員問題優先處理',
                cs: cs,
              ),

              SizedBox(height: 32.h),

              // ── Pricing cards ──
              Obx(() {
                final monthlyProduct = sub.products
                    .firstWhereOrNull(
                        (p) => p.id == SubscriptionService.monthlyProductId);
                final yearlyProduct = sub.products
                    .firstWhereOrNull(
                        (p) => p.id == SubscriptionService.yearlyProductId);

                return Column(
                  children: [
                    _PricingCard(
                      title: '年費方案',
                      price: yearlyProduct?.price ?? 'NT\$799',
                      period: '/ 年',
                      badge: '省 33%',
                      isRecommended: true,
                      onTap: sub.isLoading.value
                          ? null
                          : () => sub.purchaseSubscription(
                              SubscriptionService.yearlyProductId),
                      cs: cs,
                    ),
                    SizedBox(height: 12.h),
                    _PricingCard(
                      title: '月費方案',
                      price: monthlyProduct?.price ?? 'NT\$99',
                      period: '/ 月',
                      isRecommended: false,
                      onTap: sub.isLoading.value
                          ? null
                          : () => sub.purchaseSubscription(
                              SubscriptionService.monthlyProductId),
                      cs: cs,
                    ),
                  ],
                );
              }),

              SizedBox(height: 16.h),

              // ── Restore ──
              TextButton(
                onPressed: () async {
                  await sub.restorePurchases();
                  if (sub.isSubscribed.value) {
                    Get.snackbar('還原成功', '已恢復您的訂閱');
                  } else {
                    Get.snackbar('查無紀錄', '找不到有效的訂閱記錄');
                  }
                },
                child: Text(
                  '還原購買記錄',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),

              SizedBox(height: 8.h),

              // ── Fine print ──
              Text(
                '訂閱將透過 Apple / Google 帳號扣款\n'
                '到期前 24 小時自動續訂，可隨時至系統設定取消',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // ── Legal links ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => const LegalPage(
                          title: '使用條款',
                          assetPath: 'assets/legal/terms_of_use.html',
                        )),
                    child: Text(
                      '使用條款',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text('|',
                        style: TextStyle(
                            fontSize: 12.sp, color: cs.onSurfaceVariant)),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const LegalPage(
                          title: '隱私政策',
                          assetPath: 'assets/legal/privacy_policy.html',
                        )),
                    child: Text(
                      '隱私政策',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ─── Benefit tile ────────────────────────────────────────────────────────────

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme cs;

  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.amber[800], size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13.sp, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pricing card ────────────────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isRecommended;
  final VoidCallback? onTap;
  final ColorScheme cs;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.isRecommended,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isRecommended ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: isRecommended
            ? BorderSide(color: Colors.amber[700]!, width: 2)
            : BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600)),
                        if (badge != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber[700],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price,
                            style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 4.w),
                        Text(period,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
