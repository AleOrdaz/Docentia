import 'package:docentia/app/theme/app_colors.dart';
import 'package:docentia/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> drainFontErrors(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    Object? error;
    while ((error = tester.takeException()) != null) {
      final message = error.toString();
      final isFontError = message.contains('google_fonts') ||
          message.contains('Failed to load font') ||
          message.contains('allowRuntimeFetching');
      if (!isFontError) {
        fail('Unexpected test exception: $error');
      }
    }
  }

  group('Dark theme', () {
    test('primaryForTheme lightens Stitch blue in dark mode', () {
      final lightPrimary =
          AppColors.primaryForTheme(AppColors.primary, Brightness.light);
      final darkPrimary =
          AppColors.primaryForTheme(AppColors.primary, Brightness.dark);

      expect(lightPrimary, AppColors.primary);
      expect(darkPrimary, isNot(AppColors.primary));
      expect(
        HSLColor.fromColor(darkPrimary).lightness,
        greaterThan(HSLColor.fromColor(AppColors.primary).lightness),
      );
      expect(
        HSLColor.fromColor(darkPrimary).lightness,
        greaterThanOrEqualTo(0.45),
      );
    });

    testWidgets('getDarkTheme uses dark brightness, scaffold and primary',
        (tester) async {
      final theme = AppTheme.getDarkTheme(AppColors.primary);
      final expectedPrimary =
          AppColors.primaryForTheme(AppColors.primary, Brightness.dark);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0B132B));
      expect(theme.colorScheme.onSurface, const Color(0xFFF8FAFC));
      expect(theme.colorScheme.primary, expectedPrimary);

      await drainFontErrors(tester);
    });

    testWidgets('ThemeMode.dark resolves MaterialApp to dark brightness',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getTheme(AppColors.primary),
          darkTheme: AppTheme.getDarkTheme(AppColors.primary),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              return Scaffold(
                body: Text('mode:$brightness'),
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.text('mode:Brightness.dark'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(Scaffold))).brightness,
        Brightness.dark,
      );
      await drainFontErrors(tester);
    });

    testWidgets('ThemeMode.light resolves MaterialApp to light brightness',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getTheme(AppColors.primary),
          darkTheme: AppTheme.getDarkTheme(AppColors.primary),
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              return Scaffold(
                body: Text('mode:$brightness'),
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.text('mode:Brightness.light'), findsOneWidget);
      await drainFontErrors(tester);
    });
  });
}
