import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/courses_provider.dart';

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  void _openEditDialog(BuildContext context, WidgetRef ref, String currentName, String currentPhone, String currentBio) {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final bioCtrl = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n!.editProfileData, style: TextStyle(color: AppColors.textPrimary(ctx))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.profileTitle,
                labelStyle: TextStyle(color: AppColors.textSecondary(ctx)),
              ),
              style: TextStyle(color: AppColors.textPrimary(ctx)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.whatsappPhone,
                labelStyle: TextStyle(color: AppColors.textSecondary(ctx)),
              ),
              style: TextStyle(color: AppColors.textPrimary(ctx)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bioCtrl,
              decoration: InputDecoration(
                labelText: l10n.biography,
                labelStyle: TextStyle(color: AppColors.textSecondary(ctx)),
              ),
              style: TextStyle(color: AppColors.textPrimary(ctx)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.textSecondary(ctx))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).updateProfile(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                bio: bioCtrl.text.trim(),
              );
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final teacher = authState.teacher;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentThemeIndex = ref.watch(themeIndexProvider);
    final currentLocale = ref.watch(localeProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final courses = coursesAsync.value ?? [];

    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorder(context);
    final surfaceLow = AppColors.surfaceLow(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n!.profileTitle, style: AppTextStyles.titleMedium.copyWith(color: textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Tarjeta Principal de Identidad
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage(
                          teacher?.photoUrl ??
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAq9Pvt1-c4_DUZSEdXdpOvNpYKqM7LG2oVztITe-6wiQKFFoh4-H4sQdDlNWqA_9Id0qaAvcj3Npis5rwFXKgrKhHc3QkdI4L6n4p-kcXLZI-bQWLPtS_UbwgMQDxNMsAnF1QJ6LBspB_FqcsoUhlyRstSkoQN7kUtQcOQ6P1Lu4w5NPnMshS0eicJ185YYRhVTjrhbQqGstpKPgo6AubEJakMHGGmjJpMMel095xfBra2EdOFYNav',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: teacher?.provider == 'google' ? Colors.blue : Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            teacher?.provider == 'google' ? 'G' : '',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    teacher?.name ?? l10n.teacherFallback,
                    style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                  ),
                  Text(
                    teacher?.email ?? 'profesor@docentia.edu',
                    style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${l10n.linkedWith} ${teacher?.provider == 'google' ? 'Google' : 'Apple'}',
                      style: AppTextStyles.labelSmall.copyWith(color: primaryColor),
                    ),
                  ),

                  if (teacher?.bio != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      teacher!.bio!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openEditDialog(
                          context,
                          ref,
                          teacher?.name ?? '',
                          teacher?.phone ?? '',
                          teacher?.bio ?? '',
                        ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(l10n.editProfileData),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(authProvider.notifier).signOut();
                          context.go('/login');
                        },
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        icon: const Icon(Icons.logout, size: 16),
                        label: Text(l10n.signOut),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECCIÓN: Selector de Idioma (Español / English)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.languageTitle, style: AppTextStyles.titleSmall.copyWith(color: textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.languageDesc,
                    style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildLanguageOption(
                          label: 'Español',
                          flag: '🇲🇽',
                          code: 'es',
                          currentCode: currentLocale.languageCode,
                          primaryColor: primaryColor,
                          surfaceLow: surfaceLow,
                          textPrimary: textPrimary,
                          onTap: () {
                            ref.read(localeProvider.notifier).setLanguage('es');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildLanguageOption(
                          label: 'English',
                          flag: '🇺🇸',
                          code: 'en',
                          currentCode: currentLocale.languageCode,
                          primaryColor: primaryColor,
                          surfaceLow: surfaceLow,
                          textPrimary: textPrimary,
                          onTap: () {
                            ref.read(localeProvider.notifier).setLanguage('en');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECCIÓN: Personalización del Tema (10 colores)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.personalizationTitle, style: AppTextStyles.titleSmall.copyWith(color: textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.personalizationDesc,
                    style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Grid de los 10 colores
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: AppColors.selectableThemes.length,
                    itemBuilder: (ctx, index) {
                      final item = AppColors.selectableThemes[index];
                      final isSelected = currentThemeIndex == index;

                      return InkWell(
                        onTap: () {
                          ref.read(themeIndexProvider.notifier).setThemeIndex(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? item.color : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: item.color.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  item.name.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? item.color : textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECCIÓN: Modo Claro / Oscuro
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode_outlined, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.themeModeTitle, style: AppTextStyles.titleSmall.copyWith(color: textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.themeModeDesc,
                    style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 14),

                  Consumer(
                    builder: (context, ref, _) {
                      final currentMode = ref.watch(themeModeProvider);

                      return Row(
                        children: [
                          Expanded(
                            child: _buildThemeModeOption(
                              label: l10n.lightMode,
                              icon: Icons.light_mode_outlined,
                              mode: ThemeMode.light,
                              currentMode: currentMode,
                              primaryColor: primaryColor,
                              surfaceLow: surfaceLow,
                              textPrimary: textPrimary,
                              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildThemeModeOption(
                              label: l10n.darkMode,
                              icon: Icons.dark_mode_outlined,
                              mode: ThemeMode.dark,
                              currentMode: currentMode,
                              primaryColor: primaryColor,
                              surfaceLow: surfaceLow,
                              textPrimary: textPrimary,
                              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildThemeModeOption(
                              label: l10n.systemMode,
                              icon: Icons.brightness_auto_outlined,
                              mode: ThemeMode.system,
                              currentMode: currentMode,
                              primaryColor: primaryColor,
                              surfaceLow: surfaceLow,
                              textPrimary: textPrimary,
                              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String flag,
    required String code,
    required String currentCode,
    required Color primaryColor,
    required Color surfaceLow,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    final isSelected = code == currentCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.12) : surfaceLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? primaryColor : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption({
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Color primaryColor,
    required Color surfaceLow,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : surfaceLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.8,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryColor : textPrimary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
