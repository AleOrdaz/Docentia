import 'package:docentia/l10n/app_localizations.dart';
import 'package:docentia/l10n/app_localizations_en.dart';
import 'package:docentia/l10n/app_localizations_es.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Docentia Localization Tests', () {
    test('Supported locales include Spanish (es) and English (en)', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales.first, const Locale('es'));
    });

    test('Spanish translations are valid and not empty', () {
      final l10nEs = AppLocalizationsEs();
      expect(l10nEs.appName, 'Docentia');
      expect(l10nEs.navHome, 'Inicio');
      expect(l10nEs.navCourses, 'Cursos');
      expect(l10nEs.navCalendar, 'Calendario');
      expect(l10nEs.navFinance, 'Finanzas');
      expect(l10nEs.languageTitle, 'Idioma');
      expect(l10nEs.spanishLanguage, 'Español');
      expect(l10nEs.englishLanguage, 'English');
      expect(l10nEs.themeModeTitle, 'Tema Visual');
      expect(l10nEs.lightMode, 'Claro');
      expect(l10nEs.darkMode, 'Oscuro');
    });

    test('English translations are valid and properly mapped', () {
      final l10nEn = AppLocalizationsEn();
      expect(l10nEn.appName, 'Docentia');
      expect(l10nEn.navHome, 'Home');
      expect(l10nEn.navCourses, 'Courses');
      expect(l10nEn.navCalendar, 'Calendar');
      expect(l10nEn.navFinance, 'Finance');
      expect(l10nEn.languageTitle, 'Language');
      expect(l10nEn.spanishLanguage, 'Español');
      expect(l10nEn.englishLanguage, 'English');
      expect(l10nEn.themeModeTitle, 'Visual Theme');
      expect(l10nEn.lightMode, 'Light');
      expect(l10nEn.darkMode, 'Dark');
    });

    test('Delegate supports Spanish and English only', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });
}
