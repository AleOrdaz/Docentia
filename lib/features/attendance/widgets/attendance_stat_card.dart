import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class AttendanceStatCard extends StatelessWidget {
  final int currentSession;
  final int totalSessions;
  final int enrolled;
  final int present;
  final int absent;
  final int excused;
  final int capacity;

  const AttendanceStatCard({
    super.key,
    this.currentSession = 1,
    this.totalSessions = 32,
    this.enrolled = 0,
    this.present = 0,
    this.absent = 0,
    this.excused = 0,
    this.capacity = 30,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final availableSeats = capacity - enrolled > 0 ? capacity - enrolled : 0;
    final pct = enrolled > 0 ? ((present / enrolled) * 100).round() : 0;
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header discreto: Sesión + Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.sessionOf(currentSession, totalSessions),
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.todayAttendance,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Los cuatro recuadros organizados en UN SOLO RENGLÓN HORIZONTAL
          Row(
            children: [
              // 1. Inscritos
              Expanded(
                child: _buildCompactMetric(
                  label: l10n.enrolledLabel,
                  value: enrolled.toString(),
                  subtext: l10n.activeLabel,
                  icon: Icons.group,
                  iconColor: primaryColor,
                  valueColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              // 2. Presentes
              Expanded(
                child: _buildCompactMetric(
                  label: l10n.presentsLabel,
                  value: present.toString(),
                  subtext: '$pct%',
                  icon: Icons.check_circle,
                  iconColor: AppColors.secondary,
                  valueColor: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              // 3. Faltas
              Expanded(
                child: _buildCompactMetric(
                  label: l10n.absencesLabel,
                  value: absent.toString(),
                  subtext: l10n.excusedCompact(excused),
                  icon: Icons.cancel,
                  iconColor: AppColors.error,
                  valueColor: AppColors.error,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              // 4. Cupos
              Expanded(
                child: _buildCompactMetric(
                  label: l10n.spotsLabel,
                  value: availableSeats.toString(),
                  subtext: l10n.ofCapacity(capacity),
                  icon: Icons.event_seat,
                  iconColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  valueColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barra de progreso discreta
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: capacity > 0 ? (enrolled / capacity).clamp(0.0, 1.0) : 0.0,
              minHeight: 4,
              backgroundColor: isDark ? const Color(0xFF1E2A42) : AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required Color valueColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A42) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: valueColor == AppColors.secondary
                  ? AppColors.secondary
                  : valueColor == AppColors.error
                  ? AppColors.error
                  : (isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
              height: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
