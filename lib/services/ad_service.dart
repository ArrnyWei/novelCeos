import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'subscription_service.dart';

class AdService extends GetxService {
  // ── Test Ad Unit IDs ─────────────────────────────────────────────
  // Replace with real IDs from AdMob console before publishing.
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-7412511926360804/9645998957'
      : 'ca-app-pub-7412511926360804/9182964521';

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-7412511926360804/3229732011'
      : 'ca-app-pub-7412511926360804/8968443151';
  // ─────────────────────────────────────────────────────────────────

  // Frequency counters
  int _enterReaderCount = 0;
  int _chapterChangedCount = 0;
  static const int _enterReaderThreshold = 3;
  static const int _chapterChangedThreshold = 1;

  // Global interstitial cooldown (3 minutes)
  DateTime? _lastInterstitialShown;
  static const Duration _cooldown = Duration(minutes: 3);

  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;

  /// Whether MobileAds SDK has been initialized
  final isAdSdkReady = false.obs;

  bool get adsEnabled {
    if (!Get.isRegistered<SubscriptionService>()) return true;
    return !Get.find<SubscriptionService>().isSubscribed.value;
  }

  @override
  void onInit() {
    super.onInit();
    _initAdsWithTracking();
  }

  Future<void> _initAdsWithTracking() async {
    // On iOS, request ATT permission before initializing ads
    if (Platform.isIOS) {
      try {
        // Wait for app to be in foreground (required for ATT dialog)
        await Future.delayed(const Duration(seconds: 1));
        await AppTrackingTransparency.requestTrackingAuthorization();
      } catch (_) {
        // ATT may fail on some devices/simulators — continue with ad init
      }
    }
    await MobileAds.instance.initialize();
    isAdSdkReady.value = true;
    _loadInterstitial();
  }

  // ── Interstitial loading ──────────────────────────────────────────

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _loadInterstitial(); // pre-load next one
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  bool _canShowInterstitial() {
    if (!adsEnabled) return false;
    if (!_isInterstitialReady) return false;
    if (_lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShown!);
      if (elapsed < _cooldown) return false;
    }
    return true;
  }

  void _showInterstitial() {
    if (_canShowInterstitial()) {
      _lastInterstitialShown = DateTime.now();
      _interstitialAd?.show();
    }
  }

  // ── Public trigger methods ────────────────────────────────────────

  /// Call when user taps into the reader (from novel detail page).
  void onEnterReader() {
    if (!adsEnabled) return;
    _enterReaderCount++;
    if (_enterReaderCount >= _enterReaderThreshold) {
      _enterReaderCount = 0;
      _showInterstitial();
    }
  }

  /// Call when user switches chapters (next/prev).
  void onChapterChanged() {
    if (!adsEnabled) return;
    _chapterChangedCount++;
    if (_chapterChangedCount >= _chapterChangedThreshold) {
      _chapterChangedCount = 0;
      _showInterstitial();
    }
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}
