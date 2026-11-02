import 'package:docentia/core/services/storage_service.dart';
import 'package:docentia/features/subscription/models/subscription_config.dart';
import 'package:docentia/features/subscription/models/subscription_status.dart';
import 'package:docentia/features/subscription/providers/subscription_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const proFeatures = ProFeature.values;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetCacheForTest();
  });

  group('Plan Free — límites y features', () {
    test('config comercial coincide con MONETIZACION.md', () {
      expect(SubscriptionConfig.freeMaxCourses, 2);
      expect(SubscriptionConfig.freeMaxStudents, 20);
      expect(SubscriptionConfig.trialDays, 14);
      expect(SubscriptionConfig.monthlyPriceMxn, 129);
      expect(SubscriptionConfig.yearlyPriceMxn, 899);
      expect(SubscriptionConfig.yearlySavingsMxn(), (129 * 12) - 899);
    });

    test('empieza en Free sin acceso Pro', () {
      const free = SubscriptionStatus.free;

      expect(free.isPro, isFalse);
      expect(free.isOnTrial, isFalse);
      expect(free.tier, SubscriptionTier.free);

      for (final feature in proFeatures) {
        expect(
          free.canAccess(feature),
          isFalse,
          reason: 'Free no debe acceder a $feature',
        );
      }
    });

    test('permite crear cursos solo hasta el límite Free', () {
      const free = SubscriptionStatus.free;

      expect(free.canCreateCourse(0), isTrue);
      expect(free.canCreateCourse(1), isTrue);
      expect(
        free.canCreateCourse(SubscriptionConfig.freeMaxCourses),
        isFalse,
        reason: 'Con ${SubscriptionConfig.freeMaxCourses} cursos activos '
            'ya no se puede crear otro',
      );
      expect(free.canCreateCourse(3), isFalse);
      expect(free.canCreateCourse(10), isFalse);
    });

    test('permite agregar alumnos solo hasta el límite Free', () {
      const free = SubscriptionStatus.free;

      expect(free.canAddStudent(0), isTrue);
      expect(free.canAddStudent(19), isTrue);
      expect(
        free.canAddStudent(SubscriptionConfig.freeMaxStudents),
        isFalse,
        reason: 'Con ${SubscriptionConfig.freeMaxStudents} alumnos activos '
            'ya no se puede agregar otro',
      );
      expect(free.canAddStudent(21), isFalse);
      expect(free.canAddStudent(100), isFalse);
    });

    test('provider inicia en Free y respeta límites', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(subscriptionProvider.notifier);
      await notifier.ready();

      final status = container.read(subscriptionProvider);
      expect(status.isPro, isFalse);
      expect(status.canCreateCourse(2), isFalse);
      expect(status.canAddStudent(20), isFalse);
      expect(status.canAccess(ProFeature.certificates), isFalse);
      expect(status.canAccess(ProFeature.expenses), isFalse);
      expect(status.canAccess(ProFeature.reminders), isFalse);
      expect(status.canAccess(ProFeature.financeReports), isFalse);
      expect(status.canAccess(ProFeature.courseReportPdf), isFalse);
      expect(status.canAccess(ProFeature.notifyParents), isFalse);
    });
  });

  group('Compra Pro — desbloqueo completo', () {
    test('activar Pro mensual quita límites y abre todas las features', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(subscriptionProvider.notifier);
      await notifier.ready();

      // Precondición Free
      expect(container.read(subscriptionProvider).isPro, isFalse);

      await notifier.activatePro(BillingPeriod.monthly);
      final pro = container.read(subscriptionProvider);

      expect(pro.isPro, isTrue);
      expect(pro.tier, SubscriptionTier.pro);
      expect(pro.billingPeriod, BillingPeriod.monthly);
      expect(pro.isOnTrial, isFalse);
      expect(pro.proExpiresAt, isNotNull);
      expect(pro.proExpiresAt!.isAfter(DateTime.now()), isTrue);

      // Límites Free ya no aplican
      expect(pro.canCreateCourse(2), isTrue);
      expect(pro.canCreateCourse(50), isTrue);
      expect(pro.canAddStudent(20), isTrue);
      expect(pro.canAddStudent(500), isTrue);

      for (final feature in proFeatures) {
        expect(
          pro.canAccess(feature),
          isTrue,
          reason: 'Pro debe acceder a $feature',
        );
      }
    });

    test('activar Pro anual también desbloquea todo', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(subscriptionProvider.notifier);
      await notifier.ready();
      await notifier.activatePro(BillingPeriod.yearly);

      final pro = container.read(subscriptionProvider);
      expect(pro.isPro, isTrue);
      expect(pro.billingPeriod, BillingPeriod.yearly);
      expect(pro.canCreateCourse(100), isTrue);
      expect(pro.canAddStudent(1000), isTrue);
      expect(pro.canAccess(ProFeature.certificates), isTrue);
      expect(pro.canAccess(ProFeature.financeReports), isTrue);
    });

    test('Pro persiste y se recarga desde storage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(subscriptionProvider.notifier);
      await notifier.ready();
      await notifier.activatePro(BillingPeriod.yearly);

      // Nuevo contenedor = “reabrir la app”
      StorageService.resetCacheForTest();
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      final notifier2 = container2.read(subscriptionProvider.notifier);
      await notifier2.ready();
      final reloaded = container2.read(subscriptionProvider);

      expect(reloaded.isPro, isTrue);
      expect(reloaded.billingPeriod, BillingPeriod.yearly);
      expect(reloaded.canAccess(ProFeature.expenses), isTrue);
      expect(reloaded.canCreateCourse(10), isTrue);
    });

    test('flujo Free → compra Pro → downgrade vuelve a cumplir Free', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(subscriptionProvider.notifier);
      await notifier.ready();

      var status = container.read(subscriptionProvider);
      expect(status.isPro, isFalse);
      expect(status.canCreateCourse(2), isFalse);
      expect(status.canAccess(ProFeature.certificates), isFalse);

      await notifier.activatePro(BillingPeriod.monthly);
      status = container.read(subscriptionProvider);
      expect(status.isPro, isTrue);
      expect(status.canCreateCourse(2), isTrue);
      expect(status.canAccess(ProFeature.certificates), isTrue);
      expect(status.canAccess(ProFeature.reminders), isTrue);

      await notifier.downgradeToFree();
      status = container.read(subscriptionProvider);
      expect(status.isPro, isFalse);
      expect(status.tier, SubscriptionTier.free);
      expect(status.canCreateCourse(2), isFalse);
      expect(status.canAddStudent(20), isFalse);
      expect(status.canAccess(ProFeature.certificates), isFalse);
      expect(status.canAccess(ProFeature.expenses), isFalse);
      expect(status.canAccess(ProFeature.notifyParents), isFalse);
    });

    test('trial Pro desbloquea igual que una compra temporal', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(subscriptionProvider.notifier);
      await notifier.ready();
      await notifier.startTrial();

      final trial = container.read(subscriptionProvider);
      expect(trial.isPro, isTrue);
      expect(trial.isOnTrial, isTrue);
      expect(trial.canCreateCourse(99), isTrue);
      expect(trial.canAddStudent(99), isTrue);
      for (final feature in proFeatures) {
        expect(trial.canAccess(feature), isTrue);
      }
    });
  });

  group('Expiración Pro', () {
    test('Pro vencido se comporta como Free', () {
      final expired = SubscriptionStatus(
        tier: SubscriptionTier.pro,
        billingPeriod: BillingPeriod.monthly,
        proExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(expired.isPro, isFalse);
      expect(expired.canCreateCourse(2), isFalse);
      expect(expired.canAddStudent(20), isFalse);
      expect(expired.canAccess(ProFeature.certificates), isFalse);
    });
  });
}
