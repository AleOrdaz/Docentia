import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  static const double _barHeight = 62;

  static double reservedHeight(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return _barHeight + 1 + bottom + 12;
  }

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final navItems = [
      (
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
      route: '/home',
      ),
      (
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Cursos',
      route: '/courses',
      ),
      (
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Calendario',
      route: '/calendar',
      ),
      (
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Finanzas',
      route: '/finance',
      ),
    ];

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20, 0, 20, bottomPadding > 0 ? 4 : 14,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : const Color(0xFF00184D).withValues(alpha: 0.12),
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
                        ? const Color(0xE8131B2E) : const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x33FFFFFF) : const Color(0x2400184D),
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              size: 22,
                              color: iconColor,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
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
