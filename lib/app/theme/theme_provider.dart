import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import 'app_colors.dart';

class ThemeColorNotifier extends StateNotifier<int> {
  ThemeColorNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final saved = await StorageService.getThemeColorIndex();
    if (saved >= 0 && saved < AppColors.selectableThemes.length) {
      state = saved;
    }
  }

  Future<void> setThemeIndex(int index) async {
    if (index >= 0 && index < AppColors.selectableThemes.length) {
      state = index;
      await StorageService.saveThemeColorIndex(index);
    }
  }
}

final themeIndexProvider = StateNotifierProvider<ThemeColorNotifier, int>((ref) {
  return ThemeColorNotifier();
});

final currentPrimaryColorProvider = Provider<Color>((ref) {
  final index = ref.watch(themeIndexProvider);
  return AppColors.selectableThemes[index].color;
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final saved = await StorageService.getThemeMode();
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await StorageService.saveThemeMode(modeStr);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Gestor de internacionalización de Docentia (Español 'es' como idioma predeterminado)
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es')) {
    _load();
  }

  Future<void> _load() async {
    final savedCode = await StorageService.getLanguageCode();
    if (savedCode == 'en') {
      state = const Locale('en');
    } else {
      state = const Locale('es');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (state == newLocale) return;
    state = newLocale;
    await StorageService.saveLanguageCode(newLocale.languageCode);
  }

  Future<void> setLanguage(String langCode) async {
    final newLocale = Locale(langCode == 'en' ? 'en' : 'es');
    await setLocale(newLocale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
