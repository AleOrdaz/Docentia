import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/teacher_avatar.dart';
import '../../l10n/app_localizations.dart';

class AppBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;

  static const double _barHeight = 62;

  static double reservedHeight(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return _barHeight + 1 + bottom + 12;
  }

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final teacher = ref.watch(authProvider).teacher;

    final navItems = [
      (
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: l10n?.navHome ?? 'Inicio',
      route: '/home',
      isProfile: false,
      ),
      (
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      label: l10n?.navCourses ?? 'Cursos',
      route: '/courses',
      isProfile: false,
      ),
      (
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: l10n?.navCalendar ?? 'Calendario',
      route: '/calendar',
      isProfile: false,
      ),
      (
      icon: Icons.insert_chart_outlined,
      activeIcon: Icons.insert_chart,
      label: l10n?.navFinance ?? 'Finanzas',
      route: '/finance',
      isProfile: false,
      ),
      (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: l10n?.navProfile ?? 'Perfil',
      route: '/profile',
      isProfile: true,
      ),
    ];

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          0,
          12,
          bottomPadding > 0 ? 0: 4,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : primaryColor.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: _barHeight,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xE8131B2E)
                      : const Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : primaryColor.withValues(alpha: 0.14),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isActive = currentIndex == index;
                    final iconColor = isActive
                        ? primaryColor : (isDark
                        ? const Color(0xFF828C9F) : const Color(0xFF757682));

                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          if (onDestinationSelected != null) {
                            onDestinationSelected!(index);
                            return;
                          }
                          if (currentIndex != index) {
                            context.go(item.route);
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? primaryColor.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (item.isProfile)
                                TeacherAvatar(
                                  radius: 11,
                                  photoUrl: teacher?.photoUrl,
                                  name: teacher?.name,
                                )
                              else
                                Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  size: 22,
                                  color: iconColor,
                                ),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w700 : FontWeight.w500,
                                  color: iconColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isActive ? 4 : 0,
                                height: isActive ? 4 : 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}