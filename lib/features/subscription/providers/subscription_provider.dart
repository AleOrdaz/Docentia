import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/services/storage_service.dart';
import '../models/subscription_config.dart';
import '../models/subscription_status.dart';
import '../services/subscription_billing_service.dart';

enum PurchaseOutcome {
  success,
  canceled,
  pending,
  storeUnavailable,
  productMissing,
  error,
}

class PurchaseResult {
  final PurchaseOutcome outcome;
  final String? message;

  const PurchaseResult(this.outcome, [this.message]);

  bool get isSuccess => outcome == PurchaseOutcome.success;
}

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier({SubscriptionBillingService? billing})
      : _billing = billing ?? SubscriptionBillingService(),
        super(SubscriptionStatus.free) {
    _loadFuture = _bootstrap();
  }

  final SubscriptionBillingService _billing;
  late final Future<void> _loadFuture;
  StreamSubscription<StorePurchaseEvent>? _purchaseSub;
  Completer<PurchaseResult>? _pendingPurchase;

  SubscriptionBillingService get billing => _billing;

  /// Espera a que termine la carga inicial desde storage + listener de tienda.
  Future<void> ready() => _loadFuture;

  Future<void> _bootstrap() async {
    await _loadFromStorage();
    await _billing.start();
    _purchaseSub = _billing.purchaseEvents.listen(_onStoreEvent);
    // Intenta refrescar entitlement desde la tienda (sin bloquear UI).
    unawaited(_softRestore());
  }

  Future<void> _loadFromStorage() async {
    final map = await StorageService.getSubscriptionMap();
    if (map == null) {
      state = SubscriptionStatus.free;
      return;
    }
    final loaded = SubscriptionStatus.fromMap(map);
    if (!loaded.isProActive) {
      state = SubscriptionStatus.free;
      await StorageService.saveSubscriptionMap(state.toMap());
      return;
    }
    state = loaded;
  }

  Future<void> _persist() async {
    await StorageService.saveSubscriptionMap(state.toMap());
  }

  Future<void> _softRestore() async {
    try {
      if (await _billing.isStoreAvailable()) {
        await _billing.restore();
      }
    } catch (_) {}
  }

  Future<List<ProductDetails>> loadStoreProducts() => _billing.loadProducts();

  ProductDetails? storeProduct(BillingPeriod period) =>
      _billing.productFor(period);

  /// Compra Pro vía App Store / Play. En debug sin tienda, simula.
  Future<PurchaseResult> purchasePro(BillingPeriod period) async {
    await ready();

    final available = await _billing.isStoreAvailable();
    if (!available) {
      if (kDebugMode) {
        await activatePro(period, simulated: true);
        return const PurchaseResult(PurchaseOutcome.success);
      }
      return const PurchaseResult(PurchaseOutcome.storeUnavailable);
    }

    await _billing.loadProducts();
    if (_billing.productFor(period) == null) {
      if (kDebugMode) {
        await activatePro(period, simulated: true);
        return const PurchaseResult(PurchaseOutcome.success);
      }
      return const PurchaseResult(PurchaseOutcome.productMissing);
    }

    _pendingPurchase = Completer<PurchaseResult>();
    final launched = await _billing.buy(period);
    if (!launched) {
      _pendingPurchase = null;
      return const PurchaseResult(PurchaseOutcome.error, 'No se pudo iniciar la compra');
    }

    return _pendingPurchase!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => const PurchaseResult(PurchaseOutcome.canceled),
    );
  }

  /// El trial real se configura en la tienda; aquí lanza la compra (oferta intro).
  Future<PurchaseResult> startTrialPurchase({
    BillingPeriod period = BillingPeriod.yearly,
  }) {
    return purchasePro(period);
  }

  Future<PurchaseResult> restorePurchases() async {
    await ready();
    final available = await _billing.isStoreAvailable();
    if (!available) {
      return const PurchaseResult(PurchaseOutcome.storeUnavailable);
    }

    final before = state.isPro;
    _pendingPurchase = Completer<PurchaseResult>();
    await _billing.restore();

    // Si no llega evento en unos segundos, resolver según estado actual.
    Future<void>.delayed(const Duration(seconds: 3), () {
      final pending = _pendingPurchase;
      if (pending == null || pending.isCompleted) return;
      if (state.isPro) {
        pending.complete(const PurchaseResult(PurchaseOutcome.success));
      } else if (!before) {
        pending.complete(const PurchaseResult(PurchaseOutcome.error, 'empty'));
      } else {
        pending.complete(const PurchaseResult(PurchaseOutcome.success));
      }
    });

    return _pendingPurchase!.future;
  }

  void _onStoreEvent(StorePurchaseEvent event) {
    switch (event.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final period =
            SubscriptionConfig.periodForProductId(event.productId) ??
                BillingPeriod.monthly;
        unawaited(_grantPro(period, simulated: false));
        _completePending(const PurchaseResult(PurchaseOutcome.success));
        break;
      case PurchaseStatus.pending:
        // Esperar al resultado final de la tienda.
        break;
      case PurchaseStatus.canceled:
        _completePending(const PurchaseResult(PurchaseOutcome.canceled));
        break;
      case PurchaseStatus.error:
        _completePending(
          PurchaseResult(PurchaseOutcome.error, event.errorMessage),
        );
        break;
    }
  }

  void _completePending(PurchaseResult result) {
    final pending = _pendingPurchase;
    if (pending != null && !pending.isCompleted) {
      pending.complete(result);
    }
    _pendingPurchase = null;
  }

  Future<void> _grantPro(BillingPeriod period, {required bool simulated}) async {
    final now = DateTime.now();
    final expires = period == BillingPeriod.yearly
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(now.year, now.month + 1, now.day);
    state = SubscriptionStatus(
      tier: SubscriptionTier.pro,
      billingPeriod: period,
      trialEndsAt: null,
      // Cache local de cortesía; la fuente de verdad es la tienda vía restore.
      proExpiresAt: expires,
      isSimulated: simulated,
    );
    await _persist();
  }

  /// Activa Pro en cache local (tests / debug sin Store).
  Future<void> activatePro(
    BillingPeriod period, {
    bool simulated = true,
  }) async {
    await ready();
    await _grantPro(period, simulated: simulated);
  }

  /// Trial local solo para debug/tests. En producción usa oferta de la tienda.
  Future<void> startTrial() async {
    await ready();
    final ends = DateTime.now().add(
      const Duration(days: SubscriptionConfig.trialDays),
    );
    state = SubscriptionStatus(
      tier: SubscriptionTier.pro,
      billingPeriod: null,
      trialEndsAt: ends,
      proExpiresAt: ends,
      isSimulated: true,
    );
    await _persist();
  }

  Future<void> downgradeToFree() async {
    await ready();
    state = SubscriptionStatus.free;
    await StorageService.clearSubscription();
  }

  @override
  void dispose() {
    unawaited(_purchaseSub?.cancel());
    unawaited(_billing.dispose());
    super.dispose();
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  return SubscriptionNotifier();
});

/// Productos/precios de la tienda (vacío si no hay IAP configurado aún).
final storeProductsProvider =
    FutureProvider<Map<BillingPeriod, ProductDetails>>((ref) async {
  final notifier = ref.watch(subscriptionProvider.notifier);
  await notifier.ready();
  final list = await notifier.loadStoreProducts();
  final map = <BillingPeriod, ProductDetails>{};
  for (final p in list) {
    final period = SubscriptionConfig.periodForProductId(p.id);
    if (period != null) map[period] = p;
  }
  return map;
});
