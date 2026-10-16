import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Versión
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    l10n.appVersion,
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                  ),
                ),
              ),

              // Contenido central
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida/AEtjO1XZ7e43VHwBaPjFd1fOXBK0dlNY57Cc-YaMli2NYFc7OQVOWhzSaCAAOv33tNxuQb5vMAA_0qf6G4ycivHEpU8c-KfCGJwd53WxGOMUvTLC3ge96FKHXlIz1rgDw3wCd6TeR7Bm0CXHYF_v6T06P5kmr3Tnm0iTTdVDWW7WTTYpUpOZxNdbsNXVzsJ-ny7otBxpWByZcXqmvsMI8NEFvjZjAJRYTKdtgdPklwiWkfoPh0JSobhTqsPxmiM',
                      errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 36, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(l10n.appName, style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginShortSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // Botón Google
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signInWithGoogle();
                        if (context.mounted) context.go('/home');
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4285F4),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.continueWithGoogleShort, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón Apple
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signInWithApple();
                        if (context.mounted) context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(l10n.continueWithApple, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Términos y privacidad
              Column(
                children: [
                  Text(l10n.termsPrefix, style: AppTextStyles.labelSmall),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.termsLink, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text(' • ', style: AppTextStyles.labelSmall),
                      Text(l10n.privacyLink, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
