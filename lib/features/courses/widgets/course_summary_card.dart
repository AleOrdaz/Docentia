import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../students/providers/students_provider.dart';
import '../models/course_icon_helper.dart';
import '../models/course_model.dart';

class CourseSummaryCard extends ConsumerWidget {
  final Course course;
  final VoidCallback onTap;
  final bool showBilling;
  final bool showStatus;

  const CourseSummaryCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showBilling = true,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentsCount =
        ref.watch(studentsForCourseProvider(course.id)).value?.length ?? 0;
    final iconData = getCourseIcon(course.iconKey);
    final iconColors = getCourseIconColors(course.iconKey);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368);
    final titleColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D);
    final scheduleGroups = <String, List<int>>{};
    for (final item in course.effectiveClassSchedules) {
      final range = item.startTime.isNotEmpty && item.endTime.isNotEmpty
          ? '${item.startTime} - ${item.endTime}'
          : item.startTime;
      scheduleGroups.putIfAbsent(range, () => []).add(item.weekday);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color.fromRGBO(0, 35, 111, 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColors.background(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(iconData, size: 24, color: iconColors.icon(isDark)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showStatus && course.active)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                l10n?.courseActiveBadge ?? 'Activo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFF047857),
                                ),
                              ),
                            ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF00174D),
                          ),
                        ],
                      ),
                      if (scheduleGroups.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 3,
                          children: [
                            for (final day in course.effectiveClassDays)
                              _dayChip(context, day, isDark: isDark),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                scheduleGroups.length > 1
                                    ? (Localizations.localeOf(context)
                                                .languageCode ==
                                            'en'
                                        ? 'Mixed schedule'
                                        : 'Horario mixto')
                                    : scheduleGroups.keys.first,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: muted,
                                ),
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Semantics(
                              label:
                                  '$studentsCount ${studentsCount == 1 ? (l10n?.studentSingular ?? 'alumno') : (l10n?.studentPlural ?? 'alumnos')}',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group_outlined,
                                      size: 14, color: muted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$studentsCount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (showBilling) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined, size: 18, color: muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_formatCourseCost(course.cost)} / ${_billingUnit(context)} · ${_dueLabel(context)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dayChip(
    BuildContext context,
    int weekday, {
    required bool isDark,
  }) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368);
    const spanish = {
      1: 'Lu',
      2: 'Ma',
      3: 'Mi',
      4: 'Ju',
      5: 'Vi',
      6: 'Sá',
      7: 'Do',
    };
    const english = {
      1: 'Mo',
      2: 'Tu',
      3: 'We',
      4: 'Th',
      5: 'Fr',
      6: 'Sa',
      7: 'Su',
    };
    const spanishFull = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };
    const englishFull = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return Tooltip(
      message: (isEnglish ? englishFull : spanishFull)[weekday] ?? '',
      child: Container(
        width: 26,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          (isEnglish ? english : spanish)[weekday] ?? '',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatCourseCost(double cost) {
    final formatted = formatCurrency(cost);
    return formatted.endsWith('.00')
        ? formatted.substring(0, formatted.length - 3)
        : formatted;
  }

  String _billingUnit(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return switch (course.billingFrequency) {
      BillingFrequency.perClass => isEnglish ? 'day' : 'día',
      BillingFrequency.weekly => isEnglish ? 'week' : 'semana',
      BillingFrequency.biweekly => isEnglish ? '2 weeks' : 'quincena',
      BillingFrequency.monthly => isEnglish ? 'month' : 'mes',
    };
  }

  String _dueLabel(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return switch (course.billingFrequency) {
      BillingFrequency.perClass =>
        isEnglish ? 'due every day' : 'vence cada día',
      BillingFrequency.weekly =>
        isEnglish ? 'due every week' : 'vence cada semana',
      BillingFrequency.biweekly =>
        isEnglish ? 'due every 2 weeks' : 'vence cada quincena',
      BillingFrequency.monthly => isEnglish
          ? (course.paymentSchedule == PaymentSchedule.firstHalf
              ? 'due on the 15th'
              : 'due at month end')
          : (course.paymentSchedule == PaymentSchedule.firstHalf
              ? 'vence el 15'
              : 'vence a fin de mes'),
    };
  }
}
