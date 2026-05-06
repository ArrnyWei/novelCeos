import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/subscription_service.dart';
import 'remove_ads_chip.dart';

/// Adaptive banner ad. Returns SizedBox.shrink() for subscribed users.
/// 透過 [Obx] 訂閱 [SubscriptionService.isSubscribed]，使用者升級的瞬間
/// 自動 collapse + dispose loaded banner。
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Worker? _sdkReadyWorker;
  Worker? _subscribedWorker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _waitForSdkAndLoad();
    _watchSubscriptionChanges();
  }

  /// 訂閱狀態 false → true 時，立刻 dispose 已載入的 banner，
  /// 避免畫面殘留。
  void _watchSubscriptionChanges() {
    if (!Get.isRegistered<SubscriptionService>()) return;
    _subscribedWorker?.dispose();
    _subscribedWorker = ever(
      Get.find<SubscriptionService>().isSubscribed,
      (subscribed) {
        if (subscribed && mounted) {
          _bannerAd?.dispose();
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        }
      },
    );
  }

  void _waitForSdkAndLoad() {
    final adService = Get.isRegistered<AdService>() ? Get.find<AdService>() : null;
    if (adService == null || !adService.adsEnabled) return;

    if (adService.isAdSdkReady.value) {
      _loadAd();
    } else {
      _sdkReadyWorker?.dispose();
      _sdkReadyWorker = ever(adService.isAdSdkReady, (ready) {
        if (ready) {
          _sdkReadyWorker?.dispose();
          _sdkReadyWorker = null;
          _loadAd();
        }
      });
    }
  }

  Future<void> _loadAd() async {
    final adService = Get.isRegistered<AdService>() ? Get.find<AdService>() : null;
    if (adService == null || !adService.adsEnabled) return;

    final width = MediaQuery.of(context).size.width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: size ?? AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          // 載完才發現使用者已訂閱 → 直接丟掉
          final adService = Get.isRegistered<AdService>()
              ? Get.find<AdService>()
              : null;
          if (adService == null || !adService.adsEnabled) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (_, __) {},
      ),
    ).load();
  }

  @override
  void dispose() {
    _sdkReadyWorker?.dispose();
    _subscribedWorker?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final adService =
          Get.isRegistered<AdService>() ? Get.find<AdService>() : null;
      // 直接讀 isSubscribed 讓 Obx 訂閱反應
      final subscribed = Get.isRegistered<SubscriptionService>() &&
          Get.find<SubscriptionService>().isSubscribed.value;
      if (adService == null || subscribed) return const SizedBox.shrink();
      if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RemoveAdsChip(),
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ],
        ),
      );
    });
  }
}
