import 'package:flutter/material.dart';

/// Paleta de colores oficial extraída de Google Stitch (Material 3)
class AppColors {
  // Primario por defecto
  static const Color primary = Color(0xFF00236F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimaryContainer = Color(0xFF90A8FF);
  static const Color primaryFixed = Color(0xFFDCE1FF);
  static const Color onPrimaryFixed = Color(0xFF00164E);

  // 10 Colores seleccionables para personalización del profesor
  static const List<({String name, Color color})> selectableThemes = [
    (name: 'Azul Stitch (Predeterminado)', color: Color(0xFF00236F)),
    (name: 'Índigo Real', color: Color(0xFF1E40AF)),
    (name: 'Verde Esmeralda', color: Color(0xFF0F766E)),
    (name: 'Violeta Ejecutivo', color: Color(0xFF581C87)),
    (name: 'Vino Tinto', color: Color(0xFF881337)),
    (name: 'Cobalto Marino', color: Color(0xFF0284C7)),
    (name: 'Pizarra Carbón', color: Color(0xFF1E293B)),
    (name: 'Terracota Cálido', color: Color(0xFF7C2D12)),
    (name: 'Rosa Frambuesa', color: Color(0xFFD81B60)),
    (name: 'Gris Neutro', color: Color(0xFF4B5563)),
  ];

  // Secundarios (Asistencia / Presente)
  static const Color secondary = Color(0xFF006A61);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF86F2E4);
  static const Color onSecondaryContainer = Color(0xFF006F66);
  static const Color secondaryFixed = Color(0xFF89F5E7);

  // Superficies
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Textos y contornos
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF444651);
  static const Color outline = Color(0xFF757682);
  static const Color outlineVariant = Color(0xFFC5C5D3);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // Errores / Faltas / Vencido
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Advertencia / Próximo a vencer
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  // Canales y WhatsApp
  static const Color whatsapp = Color(0xFF25D366);

  /// Aclara primarios muy oscuros para que sean legibles sobre fondos dark.
  static Color primaryForTheme(Color primary, Brightness brightness) {
    if (brightness != Brightness.dark) return primary;
    final hsl = HSLColor.fromColor(primary);
    if (hsl.lightness >= 0.45) return primary;
    return hsl
        .withLightness(0.55)
        .withSaturation(hsl.saturation.clamp(0.35, 0.75))
        .toColor();
  }

  // Adaptativos según el tema activo (Dark / Light)
  static Color cardBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF151D2E) : const Color(0xFFFFFFFF);
  }

  static Color cardBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9);
  }

  static Color surfaceLowest(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF151D2E) : surfaceContainerLowest;
  }

  static Color surfaceLow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E2A42) : const Color(0xFFEFF4FF);
  }

  static Color surfaceMid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF243352) : surfaceContainer;
  }

  static Color surfaceHigh(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2A3958) : const Color(0xFFDCE9FF);
  }

  static Color textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0B1C30);
  }

  static Color textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF444651);
  }

  static Color outlineAdaptive(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF64748B) : outline;
  }

  static Color outlineVariantAdaptive(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF334155) : outlineVariant;
  }
}
