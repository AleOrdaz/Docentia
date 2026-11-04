import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/payment_model.dart';
import 'payments_provider.dart';

/// Tras sync de cuotas, avisa al docente (local, máx. 1 vez/día) si hay vencidos.
final overdueTeacherNotifyProvider = FutureProvider<bool>((ref) async {
  await ref.watch(autoGenerateFeesProvider.future);

  final payments = await ref.read(paymentsRepositoryProvider).getAllPayments();
  final overdueCount =
      payments.where((p) => p.status == PaymentStatus.overdue).length;
  if (overdueCount <= 0) return false;

  final notifications = LocalNotificationService.instance;
  if (await notifications.wasNotifiedToday()) return false;

  final permitted = await notifications.requestPermissionIfNeeded();
  if (!permitted) return false;

  final lang = await StorageService.getLanguageCode();
  final l10n = lookupAppLocalizations(Locale(lang));

  await notifications.showOverdueFees(
    title: l10n.overdueFeesNotificationTitle,
    body: l10n.overdueFeesNotificationBody(overdueCount),
  );
  await notifications.markNotifiedToday();
  return true;
});
