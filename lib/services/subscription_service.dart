import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class SubscriptionService extends GetxService {
  static const _expiryKey = 'subscriptionExpiry';
  static const _isLifetimeKey = 'subscriptionLifetime';

  // Replace with your actual product IDs from App Store / Play Console
  static const String monthlyProductId = 'no_comercial';
  static const String yearlyProductId = 'no_comercial_year';
  static const String lifetimeProductId = 'no_comercial_lifetime';

  static const _productIds = {
    monthlyProductId,
    yearlyProductId,
    lifetimeProductId,
  };

  final _storage = GetStorage();
  final _iap = InAppPurchase.instance;

  final isSubscribed = false.obs;
  final isLifetime = false.obs;
  final expiryDate = Rxn<DateTime>();
  final isLoading = false.obs;
  final products = <ProductDetails>[].obs;

  /// 是否有任一訂閱 product 提供「免費試用」（StoreKit introductoryPrice
  /// + paymentMode == freeTrial）。終身方案不適用。
  final hasFreeTrialOffer = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _restoreCachedStatus();
    initialize();
  }

  void _restoreCachedStatus() {
    // 終身方案優先：永久 unlock，沒有 expiry
    if (_storage.read<bool>(_isLifetimeKey) == true) {
      isLifetime.value = true;
      isSubscribed.value = true;
      return;
    }
    final raw = _storage.read<String>(_expiryKey);
    if (raw != null) {
      final expiry = DateTime.tryParse(raw);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        expiryDate.value = expiry;
        isSubscribed.value = true;
      }
    }
  }

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    debugPrint('[SubscriptionService] IAP available: $available');
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (e) => debugPrint('[SubscriptionService] stream error: $e'),
    );

    await _loadProducts();
    await checkStatus();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    products.assignAll(response.productDetails);
    _detectFreeTrialOffer();
    debugPrint('[SubscriptionService] loaded ${products.length} products: '
        '${products.map((p) => '${p.id}=${p.price}').join(', ')}; '
        'freeTrial=${hasFreeTrialOffer.value}');
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[SubscriptionService] NOT FOUND IDs: ${response.notFoundIDs}');
    }
  }

  /// 掃描所有 product，看是否有任何 iOS 訂閱 product 帶 Free Trial introductory
  /// offer。有 → UI 可顯示「免費試用 7 天」CTA；沒有 → 自動隱藏。
  void _detectFreeTrialOffer() {
    var found = false;
    for (final p in products) {
      if (p is AppStoreProductDetails) {
        final intro = p.skProduct.introductoryPrice;
        if (intro != null &&
            intro.paymentMode == SKProductDiscountPaymentMode.freeTrail) {
          found = true;
          break;
        }
      }
    }
    hasFreeTrialOffer.value = found;
  }

  Future<void> checkStatus() async {
    isLoading.value = true;
    try {
      await _iap.restorePurchases();
      // Result handled in _handlePurchaseUpdates
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseSubscription(String productId) async {
    final match = products.firstWhereOrNull((p) => p.id == productId);
    if (match == null) {
      debugPrint('[SubscriptionService] product "$productId" not found in ${products.length} loaded products');
      Get.snackbar('無法購買', '目前無法取得訂閱產品，請稍後再試');
      return;
    }
    final param = PurchaseParam(productDetails: match);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    isLoading.value = true;
    try {
      await _iap.restorePurchases();
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (_productIds.contains(purchase.productID)) {
          _markSubscribed(purchase);
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        // Optionally show error to user
      }
    }
  }

  void _markSubscribed(PurchaseDetails purchase) {
    if (purchase.productID == lifetimeProductId) {
      // 終身方案：non-consumable，永久 unlock，沒有 expiry
      isLifetime.value = true;
      isSubscribed.value = true;
      expiryDate.value = null;
      _storage.write(_isLifetimeKey, true);
      _storage.remove(_expiryKey);
      return;
    }
    // 月/年訂閱：in_app_purchase 不暴露 server-side expiry，
    // 用 31 天 sliding window 近似（restorePurchases 會再覆蓋一次）
    final expiry = DateTime.now().add(const Duration(days: 31));
    expiryDate.value = expiry;
    isSubscribed.value = true;
    _storage.write(_expiryKey, expiry.toIso8601String());
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
