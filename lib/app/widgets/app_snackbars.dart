import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppSnackKind { success, error, warning, info }

/// Colores de snackbar adaptados al tema activo.
({Color background, Color foreground, Color icon}) appSnackColors(
  BuildContext context, {
  AppSnackKind kind = AppSnackKind.info,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final scheme = Theme.of(context).colorScheme;

  switch (kind) {
    case AppSnackKind.success:
      return (
        background: isDark ? const Color(0xFF1E3A36) : AppColors.inverseSurface,
        foreground: isDark ? const Color(0xFFCCFBF1) : AppColors.inverseOnSurface,
        icon: isDark ? const Color(0xFF5EEAD4) : AppColors.secondaryFixed,
      );
    case AppSnackKind.error:
      return (
        background: isDark ? const Color(0xFF7F1D1D) : AppColors.error,
        foreground: isDark ? const Color(0xFFFECACA) : Colors.white,
        icon: isDark ? const Color(0xFFFCA5A5) : Colors.white,
      );
    case AppSnackKind.warning:
      return (
        background: isDark ? const Color(0xFF78350F) : const Color(0xFF92400E),
        foreground: isDark ? const Color(0xFFFEF3C7) : Colors.white,
        icon: isDark ? const Color(0xFFFBBF24) : Colors.amber,
      );
    case AppSnackKind.info:
      return (
        background: isDark ? const Color(0xFF334155) : AppColors.inverseSurface,
        foreground: isDark ? const Color(0xFFF8FAFC) : AppColors.inverseOnSurface,
        icon: isDark ? scheme.primary : AppColors.inverseOnSurface,
      );
  }
}

SnackBarThemeData appSnackBarTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: isDark ? const Color(0xFF334155) : AppColors.inverseSurface,
    contentTextStyle: TextStyle(
      color: isDark ? const Color(0xFFF8FAFC) : AppColors.inverseOnSurface,
      fontWeight: FontWeight.w500,
    ),
    actionTextColor: isDark ? const Color(0xFF93C5FD) : AppColors.inverseOnSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: isDark ? 4 : 2,
  );
}

/// Muestra una snackbar con contraste correcto en light y dark.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackKind kind = AppSnackKind.info,
  IconData? icon,
  bool floating = true,
  ScaffoldMessengerState? messenger,
}) {
  final colors = appSnackColors(context, kind: kind);
  final resolvedIcon = icon ??
      switch (kind) {
        AppSnackKind.success => Icons.check_circle,
        AppSnackKind.error => Icons.error_outline,
        AppSnackKind.warning => Icons.warning_amber_rounded,
        AppSnackKind.info => null,
      };

  final snackBar = SnackBar(
    content: Row(
      children: [
        if (resolvedIcon != null) ...[
          Icon(resolvedIcon, color: colors.icon, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: colors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: colors.background,
    behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(floating ? 14 : 8),
    ),
  );

  (messenger ?? ScaffoldMessenger.of(context))
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
