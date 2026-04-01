import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService extends GetxService {
  static const _expiryKey = 'subscriptionExpiry';

  // Replace with your actual product IDs from App Store / Play Console
  static const String monthlyProductId = 'no_comercial';
  static const String yearlyProductId = 'no_comercial_year';

  static const _productIds = {monthlyProductId, yearlyProductId};

  final _storage = GetStorage();
  final _iap = InAppPurchase.instance;

  final isSubscribed = false.obs;
  final expiryDate = Rxn<DateTime>();
  final isLoading = false.obs;
  final products = <ProductDetails>[].obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _restoreCachedStatus();
    initialize();
  }

  void _restoreCachedStatus() {
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
    debugPrint('[SubscriptionService] loaded ${products.length} products: '
        '${products.map((p) => '${p.id}=${p.price}').join(', ')}');
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[SubscriptionService] NOT FOUND IDs: ${response.notFoundIDs}');
    }
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
    // in_app_purchase doesn't expose expiry natively without server receipt
    // validation. We approximate with a 31-day window from now and cache it.
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
