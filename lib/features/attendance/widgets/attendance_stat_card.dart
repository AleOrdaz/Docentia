import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

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
    final availableSeats = capacity - enrolled > 0 ? capacity - enrolled : 0;
    final pct = enrolled > 0 ? ((present / enrolled) * 100).round() : 0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: Offset(0, 1),
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
                    'Sesión $currentSession de $totalSessions',
                    style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                  ),
                ],
              ),
              Text(
                'Hoy, Asistencia',
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
                  label: 'Inscritos',
                  value: enrolled.toString(),
                  subtext: 'Activos',
                  icon: Icons.group,
                  iconColor: primaryColor,
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              // 2. Presentes
              Expanded(
                child: _buildCompactMetric(
                  label: 'Presentes',
                  value: present.toString(),
                  subtext: '$pct%',
                  icon: Icons.check_circle,
                  iconColor: AppColors.secondary,
                  valueColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 6),
              // 3. Faltas
              Expanded(
                child: _buildCompactMetric(
                  label: 'Faltas',
                  value: absent.toString(),
                  subtext: excused > 0 ? '$excused just.' : '0 just.',
                  icon: Icons.cancel,
                  iconColor: AppColors.error,
                  valueColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 6),
              // 4. Cupos
              Expanded(
                child: _buildCompactMetric(
                  label: 'Cupos',
                  value: availableSeats.toString(),
                  subtext: 'De $capacity',
                  icon: Icons.event_seat,
                  iconColor: AppColors.onSurfaceVariant,
                  valueColor: AppColors.onSurface,
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
              backgroundColor: AppColors.surfaceContainer,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
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
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
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
                  : AppColors.onSurfaceVariant,
              height: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
