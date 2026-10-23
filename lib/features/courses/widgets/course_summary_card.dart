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

  const CourseSummaryCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showBilling = true,
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
    final titleColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D);

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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColors.background(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData,
                    size: 26,
                    color: iconColors.icon(isDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13, color: muted),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              course.getLocalizedSchedule(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.group_outlined, size: 13, color: muted),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '$studentsCount ${studentsCount == 1
                                  ? (l10n?.studentSingular ?? 'alumno')
                                  : (l10n?.studentPlural ?? 'alumnos')}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (course.active)
                      Container(
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
              ],
            ),
            if (showBilling) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF452205)
                                : const Color(0xFFFFF4DE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${formatCurrency(course.cost)} / ${l10n?.perMonth ?? 'mes'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              Text(
                                l10n?.courseFee ?? 'Cuota del curso',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 15, color: muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l10n?.duePrefix ?? 'Vence'}: ${course.paymentSchedule.getLocalizedName(context)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
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
    );
  }
}
