import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

class DocentiaApp extends ConsumerWidget {
  const DocentiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final primaryColor = ref.watch(currentPrimaryColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Docentia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(primaryColor),
      darkTheme: AppTheme.getDarkTheme(primaryColor),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
