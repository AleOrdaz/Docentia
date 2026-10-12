import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D33) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: bottomPadding > 0 ? bottomPadding : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isActive = currentIndex == index;
          final iconColor = isActive
              ? primaryColor
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

          return Expanded(
            child: InkWell(
              onTap: () {
                if (currentIndex != index) {
                  context.go(item.route);
                }
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 26,
                      color: iconColor,
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? primaryColor : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
