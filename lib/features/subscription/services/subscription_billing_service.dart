import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/subscription_config.dart';

/// Resultado de una compra / restore procesado por la tienda.
class StorePurchaseEvent {
  final String productId;
  final PurchaseStatus status;
  final String? errorMessage;
  final bool isSimulated;

  const StorePurchaseEvent({
    required this.productId,
    required this.status,
    this.errorMessage,
    this.isSimulated = false,
  });
}

/// Encapsula App Store / Play Billing vía `in_app_purchase`.
class SubscriptionBillingService {
  SubscriptionBillingService({InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _events = StreamController<StorePurchaseEvent>.broadcast();

  final Map<String, ProductDetails> _products = {};

  Stream<StorePurchaseEvent> get purchaseEvents => _events.stream;

  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  ProductDetails? productFor(BillingPeriod period) =>
      _products[SubscriptionConfig.productIdFor(period)];

  bool get hasStoreProducts => _products.isNotEmpty;

  Future<void> start() async {
    if (_subscription != null) return;
    try {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onError: (Object e) {
          _events.add(
            StorePurchaseEvent(
              productId: '',
              status: PurchaseStatus.error,
              errorMessage: e.toString(),
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IAP purchaseStream unavailable: $e');
      }
    }
  }

  Future<bool> isStoreAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Carga precios/títulos reales desde la tienda.
  Future<List<ProductDetails>> loadProducts() async {
    final available = await isStoreAvailable();
    if (!available) {
      _products.clear();
      return const [];
    }

    try {
      final response =
          await _iap.queryProductDetails(SubscriptionConfig.productIds);
      _products
        ..clear()
        ..addEntries(
          response.productDetails.map((p) => MapEntry(p.id, p)),
        );
      return response.productDetails;
    } catch (_) {
      _products.clear();
      return const [];
    }
  }

  /// Inicia la compra del periodo. Devuelve `false` si no se pudo lanzar el sheet.
  Future<bool> buy(BillingPeriod period) async {
    final available = await isStoreAvailable();
    if (!available) return false;

    if (_products.isEmpty) {
      await loadProducts();
    }
    final product = productFor(period);
    if (product == null) return false;

    try {
      final param = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (_) {
      return false;
    }
  }

  Future<void> restore() async {
    final available = await isStoreAvailable();
    if (!available) return;
    try {
      await _iap.restorePurchases();
    } catch (_) {}
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      _events.add(
        StorePurchaseEvent(
          productId: purchase.productID,
          status: purchase.status,
          errorMessage: purchase.error?.message,
        ),
      );

      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('completePurchase failed: $e');
          }
        }
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _events.close();
  }
}
