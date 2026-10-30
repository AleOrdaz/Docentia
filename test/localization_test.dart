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
      expect(l10nEs.navProfile, 'Perfil');
      expect(l10nEs.languageTitle, 'Idioma');
      expect(l10nEs.spanishLanguage, 'Español');
      expect(l10nEs.englishLanguage, 'English');
      expect(l10nEs.themeModeTitle, 'Tema Visual');
      expect(l10nEs.lightMode, 'Claro');
      expect(l10nEs.darkMode, 'Oscuro');
      expect(l10nEs.loginSignIn, 'Iniciar sesión');
      expect(l10nEs.loginForgotPassword, '¿Olvidaste tu contraseña?');
      expect(l10nEs.homeGreeting('Antonio'), 'Hola, Antonio');
      expect(
        l10nEs.summarySubtitle,
        'Este es el resumen general\nde tus cursos',
      );
      expect(l10nEs.homeShortcutsTitle, 'Accesos rápidos');
      expect(l10nEs.homeActivityTitle, 'Tu actividad de hoy');
      expect(l10nEs.newEventShortcut, 'Nuevo evento');
      expect(l10nEs.pendingPaymentSingular, 'pago pendiente');
      expect(l10nEs.pendingPaymentPlural, 'pagos pendientes');
      expect(l10nEs.relationshipLabel, 'Parentesco');
      expect(l10nEs.relationshipMother, 'Madre');
      expect(l10nEs.relationshipFather, 'Padre');
      expect(l10nEs.relationshipTutor, 'Tutor');
      expect(l10nEs.certificatesBtn, 'Certificados');
      expect(l10nEs.certificateTypeApproval, 'Aprobación');
      expect(l10nEs.courseReportBtn, 'Reporte');
      expect(l10nEs.financeExportPdf, 'Exportar PDF');
      expect(l10nEs.courseNextClass, 'Próxima clase');
      expect(l10nEs.courseStudentCountLabel, 'Cantidad de alumnos');
      expect(l10nEs.paymentOnTime, 'Al día');
      expect(l10nEs.emptyStudentsTitle, 'Aún no hay alumnos');
    });

    test('English translations are valid and properly mapped', () {
      final l10nEn = AppLocalizationsEn();
      expect(l10nEn.appName, 'Docentia');
      expect(l10nEn.navHome, 'Home');
      expect(l10nEn.navCourses, 'Courses');
      expect(l10nEn.navCalendar, 'Calendar');
      expect(l10nEn.navFinance, 'Finance');
      expect(l10nEn.navProfile, 'Profile');
      expect(l10nEn.languageTitle, 'Language');
      expect(l10nEn.spanishLanguage, 'Español');
      expect(l10nEn.englishLanguage, 'English');
      expect(l10nEn.themeModeTitle, 'Visual Theme');
      expect(l10nEn.lightMode, 'Light');
      expect(l10nEn.darkMode, 'Dark');
      expect(l10nEn.loginSignIn, 'Sign in');
      expect(l10nEn.loginForgotPassword, 'Forgot your password?');
      expect(l10nEn.homeGreeting('Antonio'), 'Hello, Antonio');
      expect(
        l10nEn.summarySubtitle,
        'This is the general summary\nof your courses',
      );
      expect(l10nEn.homeShortcutsTitle, 'Quick access');
      expect(l10nEn.homeActivityTitle, 'Your activity today');
      expect(l10nEn.newEventShortcut, 'New event');
      expect(l10nEn.pendingPaymentSingular, 'pending payment');
      expect(l10nEn.pendingPaymentPlural, 'pending payments');
      expect(l10nEn.relationshipLabel, 'Relationship');
      expect(l10nEn.relationshipMother, 'Mother');
      expect(l10nEn.relationshipFather, 'Father');
      expect(l10nEn.relationshipTutor, 'Tutor');
      expect(l10nEn.certificatesBtn, 'Certificates');
      expect(l10nEn.certificateTypeApproval, 'Approval');
      expect(l10nEn.courseReportBtn, 'Report');
      expect(l10nEn.financeExportPdf, 'Export PDF');
      expect(l10nEn.courseNextClass, 'Next class');
      expect(l10nEn.courseStudentCountLabel, 'Number of students');
      expect(l10nEn.paymentOnTime, 'Up to date');
      expect(l10nEn.emptyStudentsTitle, 'No students yet');
    });

    test('Delegate supports Spanish and English only', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });
}
