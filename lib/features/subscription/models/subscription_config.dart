/// Configuración comercial Free / Pro de Docentia.
///
/// Fuente de verdad para límites, precios y trial.
/// Ver también `docs/MONETIZACION.md`.
enum BillingPeriod { monthly, yearly }

enum ProFeature {
  courseLimit,
  studentLimit,
  certificates,
  courseReportPdf,
  financeReports,
  expenses,
  reminders,
  notifyParents,
}

class SubscriptionConfig {
  SubscriptionConfig._();

  /// Plan Free: máximo de cursos activos.
  static const int freeMaxCourses = 2;

  /// Plan Free: máximo de alumnos activos en total.
  static const int freeMaxStudents = 20;

  /// Días de prueba Pro (configurar igual en App Store / Play como oferta introductoria).
  static const int trialDays = 14;

  /// Precio de referencia mensual en MXN (la tienda muestra el precio local real).
  static const int monthlyPriceMxn = 129;

  /// Precio de referencia anual en MXN.
  static const int yearlyPriceMxn = 899;

  static const String currencyCode = 'MXN';

  /// Product IDs — deben coincidir exactamente con App Store Connect y Play Console.
  /// Ver `docs/IAP_SETUP.md`.
  static const String monthlyProductId = 'docentia_pro_monthly';
  static const String yearlyProductId = 'docentia_pro_yearly';

  static const Set<String> productIds = {
    monthlyProductId,
    yearlyProductId,
  };

  static String productIdFor(BillingPeriod period) =>
      period == BillingPeriod.yearly ? yearlyProductId : monthlyProductId;

  static BillingPeriod? periodForProductId(String productId) {
    if (productId == yearlyProductId) return BillingPeriod.yearly;
    if (productId == monthlyProductId) return BillingPeriod.monthly;
    return null;
  }

  static String formatPrice(int amount) => '\$$amount $currencyCode';

  static String monthlyLabel() => '${formatPrice(monthlyPriceMxn)}/mes';

  static String yearlyLabel() => '${formatPrice(yearlyPriceMxn)}/año';

  /// Ahorro aproximado del anual vs 12 × mensual.
  static int yearlySavingsMxn() =>
      (monthlyPriceMxn * 12) - yearlyPriceMxn;
}
