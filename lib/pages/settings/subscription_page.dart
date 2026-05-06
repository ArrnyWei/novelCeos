import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/subscription_service.dart';
import '../../widgets/subscription_faq_section.dart';
import 'legal_page.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = Get.find<SubscriptionService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Premium 會員')),
      body: SafeArea(
        child: Obx(() {
          if (sub.isSubscribed.value) {
            return _SubscribedView(sub: sub);
          }
          return _UpsellView(sub: sub);
        }),
      ),
    );
  }
}

// ─── Subscribed user view ───────────────────────────────────────────────────

class _SubscribedView extends StatelessWidget {
  final SubscriptionService sub;
  const _SubscribedView({required this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, size: 64.sp, color: Colors.amber[700]),
          SizedBox(height: 12.h),
          Text(
            '感謝你的支持',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            '所有 Premium 功能已啟用',
            style: TextStyle(fontSize: 14.sp, color: cs.onSurfaceVariant),
          ),
          SizedBox(height: 28.h),

          // 方案資訊卡
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: '方案',
                  value: _planLabel(sub),
                  cs: cs,
                ),
                SizedBox(height: 12.h),
                _InfoRow(
                  label: sub.isLifetime.value ? '使用期限' : '到期時間',
                  value: _expiryLabel(sub),
                  cs: cs,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          if (!sub.isLifetime.value) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _openManageSubscriptions,
                icon: const Icon(Icons.open_in_new),
                label: const Text('管理訂閱'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                await sub.restorePurchases();
                Get.snackbar(
                  sub.isSubscribed.value ? '已同步' : '查無紀錄',
                  sub.isSubscribed.value
                      ? '訂閱狀態已是最新'
                      : '找不到有效的訂閱記錄',
                );
              },
              child: const Text('還原購買記錄'),
            ),
          ),

          SizedBox(height: 24.h),
          const SubscriptionFaqSection(),
          SizedBox(height: 16.h),
          const _LegalLinks(),
        ],
      ),
    );
  }

  String _planLabel(SubscriptionService sub) {
    if (sub.isLifetime.value) return '終身解鎖';
    // 用 expiryDate 距今天數估算月/年
    final expiry = sub.expiryDate.value;
    if (expiry == null) return 'Premium';
    final days = expiry.difference(DateTime.now()).inDays;
    return days > 60 ? '年訂閱' : '月訂閱';
  }

  String _expiryLabel(SubscriptionService sub) {
    if (sub.isLifetime.value) return '永久使用';
    final e = sub.expiryDate.value;
    if (e == null) return '—';
    final m = e.month.toString().padLeft(2, '0');
    final d = e.day.toString().padLeft(2, '0');
    return '${e.year}/$m/$d';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  const _InfoRow({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

Future<void> _openManageSubscriptions() async {
  // iOS: 直接深連到「設定 → Apple ID → 訂閱」
  // Android: Play Store 訂閱管理頁
  final url = Platform.isIOS
      ? Uri.parse('https://apps.apple.com/account/subscriptions')
      : Uri.parse('https://play.google.com/store/account/subscriptions');
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

// ─── Upsell view (non-subscribed) ───────────────────────────────────────────

class _UpsellView extends StatelessWidget {
  final SubscriptionService sub;
  const _UpsellView({required this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // ── Hero ──
          Icon(Icons.workspace_premium,
              size: 64.sp, color: Colors.amber[700]),
          SizedBox(height: 12.h),
          Text(
            '沉浸閱讀，從這裡開始',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            '不被廣告打斷的小說世界',
            style: TextStyle(fontSize: 14.sp, color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // ── 7-day free trial banner（有試用 offer 才顯示） ──
          Obx(() {
            if (!sub.hasFreeTrialOffer.value) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _FreeTrialBanner(),
            );
          }),

          // ── Benefits ──
          _BenefitTile(
            icon: Icons.block,
            title: '完全無廣告',
            subtitle: '一頁一頁，只屬於你跟故事',
            cs: cs,
          ),
          _BenefitTile(
            icon: Icons.text_fields,
            title: '完整字體選擇',
            subtitle: '宋體 / 楷體 / 圓體等 4 種專業字型',
            cs: cs,
          ),
          _BenefitTile(
            icon: Icons.palette,
            title: '進階閱讀主題包',
            subtitle: '護眼黃 / 羊皮紙 / 深夜等 5 種預設主題一鍵套用',
            cs: cs,
          ),

          SizedBox(height: 24.h),

          // ── Pricing cards ──
          Obx(() {
            final hasTrial = sub.hasFreeTrialOffer.value;
            final monthlyProduct = sub.products.firstWhereOrNull(
                (p) => p.id == SubscriptionService.monthlyProductId);
            final yearlyProduct = sub.products.firstWhereOrNull(
                (p) => p.id == SubscriptionService.yearlyProductId);
            final lifetimeProduct = sub.products.firstWhereOrNull(
                (p) => p.id == SubscriptionService.lifetimeProductId);

            return Column(
              children: [
                // 主推：年訂閱（預選視覺）
                _PricingCard(
                  title: '年訂閱',
                  price: yearlyProduct?.price ?? 'NT\$880',
                  period: '/ 年',
                  badge: '最划算',
                  isRecommended: true,
                  ctaLabel: hasTrial ? '免費試 7 天' : '開始年訂閱',
                  onTap: sub.isLoading.value
                      ? null
                      : () => sub.purchaseSubscription(
                          SubscriptionService.yearlyProductId),
                  cs: cs,
                ),
                SizedBox(height: 10.h),

                // 月訂閱
                _PricingCard(
                  title: '月訂閱',
                  price: monthlyProduct?.price ?? 'NT\$120',
                  period: '/ 月',
                  ctaLabel: hasTrial ? '免費試 7 天' : '開始月訂閱',
                  onTap: sub.isLoading.value
                      ? null
                      : () => sub.purchaseSubscription(
                          SubscriptionService.monthlyProductId),
                  cs: cs,
                ),

                // 終身解鎖（product 不存在時自動隱藏）
                if (lifetimeProduct != null) ...[
                  SizedBox(height: 10.h),
                  _PricingCard(
                    title: '終身解鎖',
                    price: lifetimeProduct.price,
                    period: '一次買斷',
                    badge: '永久',
                    badgeColor: Colors.purple[700],
                    ctaLabel: '購買',
                    onTap: sub.isLoading.value
                        ? null
                        : () => sub.purchaseSubscription(
                            SubscriptionService.lifetimeProductId),
                    cs: cs,
                  ),
                ],
              ],
            );
          }),

          SizedBox(height: 16.h),

          // ── Restore ──
          TextButton(
            onPressed: () async {
              await sub.restorePurchases();
              Get.snackbar(
                sub.isSubscribed.value ? '還原成功' : '查無紀錄',
                sub.isSubscribed.value ? '已恢復您的訂閱' : '找不到有效的訂閱記錄',
              );
            },
            child: Text('還原購買記錄', style: TextStyle(fontSize: 13.sp)),
          ),

          SizedBox(height: 8.h),

          // ── Fine print ──
          Text(
            '訂閱將透過 Apple / Google 帳號扣款\n'
            '到期前 24 小時自動續訂，可隨時取消',
            style: TextStyle(
              fontSize: 11.sp,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24.h),

          // ── FAQ ──
          const SubscriptionFaqSection(),

          SizedBox(height: 16.h),

          // ── Legal links ──
          const _LegalLinks(),
        ],
      ),
    );
  }
}

// ─── Free trial banner ─────────────────────────────────────────────────────

class _FreeTrialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.18),
            Colors.orange.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber[700]!, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, size: 22.sp, color: Colors.amber[800]),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '先免費試 7 天',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '試用結束前可隨時取消，不會收費',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.amber[800], size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.sp, color: cs.onSurfaceVariant)),
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
  final Color? badgeColor;
  final bool isRecommended;
  final String ctaLabel;
  final VoidCallback? onTap;
  final ColorScheme cs;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    this.badgeColor,
    this.isRecommended = false,
    required this.ctaLabel,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final accent = badgeColor ?? Colors.amber[700]!;
    return Card(
      elevation: isRecommended ? 3 : 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: isRecommended
            ? BorderSide(color: accent, width: 2)
            : BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: isRecommended ? 18.h : 14.h,
          ),
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
                                fontSize: isRecommended ? 16.sp : 14.sp,
                                fontWeight: FontWeight.w600)),
                        if (badge != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10.sp,
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
                                fontSize: isRecommended ? 22.sp : 18.sp,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 4.w),
                        Text(period,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              isRecommended
                  ? FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                      ),
                      child: Text(
                        ctaLabel,
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                      ),
                      child: Text(ctaLabel,
                          style: TextStyle(fontSize: 12.sp)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Legal links ────────────────────────────────────────────────────────────

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
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
              style: TextStyle(fontSize: 12.sp, color: cs.onSurfaceVariant)),
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
    );
  }
}
