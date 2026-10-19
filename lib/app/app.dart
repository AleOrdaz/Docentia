import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

class DocentiaApp extends ConsumerWidget {
  const DocentiaApp({super.key});

  Brightness _resolvedBrightness(BuildContext context, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final primaryColor = ref.watch(currentPrimaryColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Docentia',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.getTheme(primaryColor),
      darkTheme: AppTheme.getDarkTheme(primaryColor),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = _resolvedBrightness(context, themeMode);
        final isDark = brightness == Brightness.dark;
        final overlay = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor:
              isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FF),
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
