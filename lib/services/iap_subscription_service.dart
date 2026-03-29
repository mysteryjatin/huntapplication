import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// iOS StoreKit purchases for subscription plans. No-op on other platforms.
class IapSubscriptionService {
  IapSubscriptionService._();
  static final IapSubscriptionService instance = IapSubscriptionService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _listening = false;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  /// Called for each purchase update (purchased, restored, error, pending).
  Future<void> Function(PurchaseDetails details)? onPurchaseUpdate;

  bool get isIosStore => !kIsWeb && Platform.isIOS;

  Future<void> _dispatchPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      final handler = onPurchaseUpdate;
      if (handler != null) {
        await handler(p);
      }
    }
  }

  Future<bool> ensureInitialized() async {
    if (!isIosStore) return false;
    if (_listening) return true;
    final available = await _iap.isAvailable();
    if (!available) return false;
    _subscription = _iap.purchaseStream.listen(
      _dispatchPurchases,
      onError: (Object e) {
        debugPrint('IAP purchase stream error: $e');
      },
    );
    _listening = true;
    return true;
  }

  /// Load product metadata from App Store Connect.
  Future<void> queryProducts(Set<String> ids) async {
    if (!isIosStore || ids.isEmpty) return;
    await ensureInitialized();
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      debugPrint('IAP queryProductDetails: ${response.error}');
    }
    for (final p in response.productDetails) {
      _products[p.id] = p;
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP products not found in App Store Connect: ${response.notFoundIDs}');
    }
  }

  ProductDetails? productForPlan(String appleProductId) {
    return _products[appleProductId];
  }

  Future<bool> buy(ProductDetails product) async {
    if (!isIosStore) return false;
    await ensureInitialized();
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    if (!isIosStore) return;
    await ensureInitialized();
    await _iap.restorePurchases();
  }

  Future<void> completePurchase(PurchaseDetails details) async {
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _listening = false;
  }
}
