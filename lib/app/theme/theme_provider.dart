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

