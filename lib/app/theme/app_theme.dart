import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => getTheme(AppColors.primary);

  static ThemeData getTheme([Color primaryColor = AppColors.primary]) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: AppColors.onPrimary,
        primaryContainer: primaryColor.withValues(alpha: 0.15),
        onPrimaryContainer: primaryColor,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: AppColors.onPrimary,
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.onPrimary,
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: AppColors.surfaceContainer,
        labelStyle: AppTextStyles.labelSmall,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme([Color primaryColor = AppColors.primary]) {
    const darkSurface = Color(0xFF1E293B);
    const darkBg = Color(0xFF0B132B);
    const onDark = Color(0xFFF8FAFC);
    const onDarkVariant = Color(0xFF94A3B8);
    final resolvedPrimary =
        AppColors.primaryForTheme(primaryColor, Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: resolvedPrimary,
        onPrimary: Colors.white,
        primaryContainer: resolvedPrimary.withValues(alpha: 0.25),
        onPrimaryContainer: Colors.white,
        secondary: const Color(0xFF14B8A6),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF0D9488).withValues(alpha: 0.3),
        onSecondaryContainer: const Color(0xFF5EEAD4),
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        errorContainer: const Color(0xFF7F1D1D),
        onErrorContainer: const Color(0xFFFCA5A5),
        surface: darkSurface,
        onSurface: onDark,
        onSurfaceVariant: onDarkVariant,
        outline: const Color(0xFF64748B),
        outlineVariant: const Color(0xFF334155),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: onDark),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: onDark),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: onDark),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: onDark),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: onDark),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: onDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: onDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: onDark),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: onDarkVariant),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: onDark),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: onDark),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: onDarkVariant),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: onDark),
        iconTheme: const IconThemeData(color: onDark),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: resolvedPrimary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: resolvedPrimary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: Color(0xFF334155),
        labelStyle: TextStyle(color: onDark, fontSize: 11),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}

