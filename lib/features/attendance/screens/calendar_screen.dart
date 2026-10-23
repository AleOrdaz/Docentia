import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../courses/widgets/course_summary_card.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../payments/services/fee_generation_service.dart';
import '../models/calendar_event_model.dart';
import '../providers/calendar_events_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDate;
  String _activeTab = 'all'; // 'all', 'classes', 'events', 'payments'

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _toDateStr(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<DateTime> _getCurrentWeekDates() {
    final now = _selectedDate;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  String _weekdayShort(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final raw = DateFormat.E(locale).format(date).replaceAll('.', '');
    if (raw.isEmpty) return '';
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String _monthYearLabel() {
    final locale = Localizations.localeOf(context).toString();
    final raw = DateFormat.MMMM(locale).format(_selectedDate);
    final month = raw.isEmpty ? '' : '${raw[0].toUpperCase()}${raw.substring(1)}';
    return '$month ${_selectedDate.year}';
  }

  String _formatSheetTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  InputDecoration _sheetInputDecoration(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.outlineVariantAdaptive(context)),
    );
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceLow(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border,
      enabledBorder: border,
    );
  }

  Widget _sheetTapField({
    required BuildContext context,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _sheetInputDecoration(context),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Modal para Crear Nuevo Evento ---
  void _openCreateEventDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.read(coursesProvider);
    final courses = coursesAsync.value ?? [];

    final titleController = TextEditingController();
    final descController = TextEditingController();

    String selectedCourseId = courses.isNotEmpty ? courses.first.id : '';
    String eventType = 'exam';
    DateTime eventDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);
    String? formError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
            final primaryColor = Theme.of(modalCtx).colorScheme.primary;
            final media = MediaQuery.of(modalCtx);
            final maxHeight = media.size.height -
                media.padding.top -
                media.viewInsets.bottom -
                8;
            final sheetColor =
                isDark ? const Color(0xFF151D2E) : Colors.white;
            final textPrimary = AppColors.textPrimary(modalCtx);

            return Padding(
              padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Material(
                    color: sheetColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.newSchoolEvent,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: textPrimary),
                                onPressed: () => Navigator.of(modalCtx).pop(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                    AppTextField(
                      label: l10n.eventTitleLabel,
                      controller: titleController,
                      hint: l10n.eventTitleHint,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 14),
                    AppFieldLabel(l10n.activityType),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        (id: 'exam', label: l10n.eventTypeExam, icon: Icons.assignment_outlined),
                        (id: 'project', label: l10n.eventTypeProject, icon: Icons.palette_outlined),
                        (id: 'meeting', label: l10n.eventTypeMeeting, icon: Icons.groups_outlined),
                        (id: 'holiday', label: l10n.eventTypeHoliday, icon: Icons.beach_access_outlined),
                        (id: 'special', label: l10n.eventTypeSpecial, icon: Icons.star_outline),
                      ].map((item) {
                        final isSel = eventType == item.id;
                        final chipColor = isSel ? Colors.white : textPrimary;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 16, color: chipColor),
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: chipColor,
                                ),
                              ),
                            ],
                          ),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => eventType = item.id);
                          },
                          selectedColor: primaryColor,
                          backgroundColor: AppColors.surfaceLow(modalCtx),
                          side: BorderSide(
                            color: isSel
                                ? primaryColor
                                : AppColors.outlineVariantAdaptive(modalCtx),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    if (courses.isNotEmpty) ...[
                      AppFieldLabel(l10n.associatedCourse),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCourseId,
                        isExpanded: true,
                        decoration: _sheetInputDecoration(modalCtx),
                        dropdownColor: sheetColor,
                        borderRadius: BorderRadius.circular(12),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text(
                              l10n.allCoursesGeneral,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...courses.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setModalState(() => selectedCourseId = val ?? '');
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppFieldLabel(l10n.dateLabel),
                    const SizedBox(height: 4),
                    _sheetTapField(
                      context: modalCtx,
                      icon: Icons.calendar_today_outlined,
                      value: DateFormat.yMMMEd(
                        Localizations.localeOf(modalCtx).toString(),
                      ).format(eventDate),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: modalCtx,
                          initialDate: eventDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => eventDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    AppFieldLabel(l10n.timeLabel),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _sheetTapField(
                            context: modalCtx,
                            icon: Icons.access_time,
                            value: _formatSheetTime(startTime),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: modalCtx,
                                initialTime: startTime,
                              );
                              if (picked == null) return;
                              setModalState(() {
                                startTime = picked;
                                final startMinutes =
                                    picked.hour * 60 + picked.minute;
                                final endMinutes =
                                    endTime.hour * 60 + endTime.minute;
                                if (endMinutes <= startMinutes) {
                                  final next = startMinutes + 60;
                                  endTime = TimeOfDay(
                                    hour: (next ~/ 60) % 24,
                                    minute: next % 60,
                                  );
                                }
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '–',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary(modalCtx),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _sheetTapField(
                            context: modalCtx,
                            icon: Icons.access_time,
                            value: _formatSheetTime(endTime),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: modalCtx,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setModalState(() => endTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l10n.descriptionInstructionsLabel,
                      controller: descController,
                      hint: l10n.descriptionHint,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                              ],
                            ),
                          ),
                        ),
                        if (formError != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFD32F2F),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      formError!,
                                      style: const TextStyle(
                                        color: Color(0xFFD32F2F),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            4,
                            20,
                            16 +
                                (media.viewInsets.bottom > 0
                                    ? 0
                                    : media.padding.bottom),
                          ),
                          child: AppPrimaryButton(
                            label: l10n.saveEvent,
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final desc = descController.text.trim();

                              if (title.isEmpty) {
                                setModalState(
                                  () => formError = l10n.eventTitleRequired,
                                );
                                return;
                              }
                              if (desc.isEmpty) {
                                setModalState(
                                  () => formError =
                                      l10n.eventDescriptionRequired,
                                );
                                return;
                              }

                              await ref
                                  .read(calendarEventsProvider.notifier)
                                  .addEvent(
                                    title: title,
                                    type: eventType,
                                    description: desc,
                                    date: _toDateStr(eventDate),
                                    startTime: _formatSheetTime(startTime),
                                    endTime: _formatSheetTime(endTime),
                                    courseId: selectedCourseId.isEmpty
                                        ? null
                                        : selectedCourseId,
                                  );

                              if (!modalCtx.mounted || !mounted) return;
                              Navigator.of(modalCtx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.eventSaved(title)),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Modal para Notificar Evento a Padres de Familia ---
  void _openShareEventDialog(BuildContext context, CalendarEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);
    final teacherName = authState.teacher?.name ?? l10n.principalTeacher;
    final allStudents = ref.read(allActiveStudentsProvider).value ?? [];

    final tutorEmails = allStudents
        .map((s) => s.tutorEmail)
        .where((e) => e.trim().isNotEmpty && e.contains('@'))
        .toSet()
        .toList();

    final allRecipients = {...tutorEmails, ...event.emailRecipients}.toList();

    final locationLine = event.location != null && event.location!.isNotEmpty
        ? l10n.locationLine(event.location!)
        : '';
    final schedule = '${event.startTime}${event.endTime != null && event.endTime!.isNotEmpty ? ' - ${event.endTime}' : ''}';
    final subject = l10n.schoolNoticeSubject(event.title, event.date);
    final body = l10n.schoolNoticeBody(
      event.title,
      event.date,
      schedule,
      locationLine,
      event.description,
      teacherName,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151D2E) : Colors.white,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mail, color: Color(0xFF0284C7), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.sendEventToParents,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF00174D),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Banner informativo de destinatarios
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0C3353)
                      : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E4D7A)
                        : const Color(0xFFBAE6FD),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: Color(0xFF0284C7), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.bccPrivacyNotice(allRecipients.length),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFE0F2FE)
                              : const Color(0xFF0C4A6E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Vista previa del mensaje
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C273D)
                      : const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2B3A55)
                        : const Color(0xFFEEF2F9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.subjectPrefix} $subject',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE6EDF8)
                            : const Color(0xFF00174D),
                      ),
                    ),
                    const Divider(height: 16),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF43474E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$subject\n\n$body'));
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.noticeCopied),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text(l10n.copyText,
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: allRecipients.isNotEmpty
                              ? allRecipients.first
                              : '',
                          queryParameters: {
                            if (allRecipients.length > 1)
                              'bcc': allRecipients.skip(1).join(','),
                            'subject': subject,
                            'body': body,
                          },
                        );

                        Navigator.of(ctx).pop();
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    l10n.noMailClient),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(l10n.openMail,
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    final coursesAsync = ref.watch(coursesProvider);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final paymentsAsync = ref.watch(allPaymentsProvider);
    final studentsAsync = ref.watch(allActiveStudentsProvider);

    final courses = coursesAsync.value ?? [];
    final allEvents = eventsAsync.value ?? [];
    final allPayments = paymentsAsync.value ?? [];
    final students = studentsAsync.value ?? [];

    final weekDates = _getCurrentWeekDates();
    final selectedDateStr = _toDateStr(_selectedDate);

    final now = DateTime.now();
    final isSelectedToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final dayClasses = courses
        .where((c) => c.active && c.isClassDay(_selectedDate))
        .toList();

    // 1. Eventos escolares registrados en la fecha
    final dayEvents =
    allEvents.where((e) => e.date == selectedDateStr).toList();

    List<Payment> feesForDay(DateTime date) {
      final day = DateTime(date.year, date.month, date.day);
      final dayKey = _toDateStr(day);
      final included = <String>{};
      final fees = <Payment>[];

      void addFee(Payment payment) {
        if (included.add(payment.id)) fees.add(payment);
      }

      bool paidOnThisDay(Payment payment) {
        final paidAt = payment.paidAt;
        if (payment.status != PaymentStatus.paid || paidAt == null) {
          return false;
        }
        return paidAt.year == day.year &&
            paidAt.month == day.month &&
            paidAt.day == day.day;
      }

      for (final payment in allPayments) {
        if (payment.dueDate == dayKey || paidOnThisDay(payment)) {
          addFee(payment);
        }
      }

      for (final course in courses.where((item) => item.active)) {
        final billing = FeeCycle.billingDate(
          course.paymentSchedule,
          day.year,
          day.month,
        );
        if (!FeeCycle.isSameDay(billing, day)) continue;

        final enrolled = students.where(
          (student) =>
              student.active &&
              student.courseId == course.id &&
              FeeCycle.wasEnrolledOn(student.createdAt, billing),
        );
        for (final student in enrolled) {
          final existing = allPayments
              .where(
                (payment) =>
                    payment.studentId == student.id &&
                    payment.courseId == course.id &&
                    payment.periodYear == billing.year &&
                    payment.periodMonth == billing.month,
              )
              .firstOrNull;
          if (existing != null) {
            addFee(existing);
            continue;
          }
          addFee(
            Payment(
              id: 'scheduled-${student.id}-${course.id}-${billing.year}-${billing.month}',
              studentId: student.id,
              courseId: course.id,
              periodMonth: billing.month,
              periodYear: billing.year,
              amount: course.cost,
              dueDate: FeeCycle.formatDate(billing),
              status: PaymentStatus.pending,
            ),
          );
        }
      }

      int statusRank(PaymentStatus status) {
        switch (status) {
          case PaymentStatus.overdue:
            return 0;
          case PaymentStatus.pending:
            return 1;
          case PaymentStatus.upcoming:
            return 2;
          case PaymentStatus.paid:
            return 3;
        }
      }

      String studentName(Payment payment) {
        final student =
            students.where((item) => item.id == payment.studentId).firstOrNull;
        if (student == null) return '';
        return '${student.name} ${student.lastName}';
      }

      fees.sort((a, b) {
        final byStatus = statusRank(a.status).compareTo(statusRank(b.status));
        if (byStatus != 0) return byStatus;
        return studentName(a).compareTo(studentName(b));
      });
      return fees;
    }

    final dayPayments = feesForDay(_selectedDate);

    // Indicadores para los días de la semana
    bool hasClasses(DateTime d) =>
        courses.any((c) => c.active && c.isClassDay(d));
    bool hasEvents(DateTime d) =>
        allEvents.any((e) => e.date == _toDateStr(d));
    bool hasPayments(DateTime d) => feesForDay(d).isNotEmpty;

    return Scaffold(
      extendBody: true,
      backgroundColor:
      isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.calendarClassesTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          8 + AppBottomNavBar.reservedHeight(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del Mes y Navegación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151D2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF22304A)
                      : const Color(0xFFEEF2F9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _monthYearLabel(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF00174D),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF00174D)),
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate
                                    .subtract(const Duration(days: 7));
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF00174D)),
                            onPressed: () {
                              setState(() {
                                _selectedDate =
                                    _selectedDate.add(const Duration(days: 7));
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Fila de los 7 días de la semana con puntos de estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekDates.map((date) {
                      final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;

                      final cHasClasses = hasClasses(date);
                      final cHasEvents = hasEvents(date);
                      final cHasPayments = hasPayments(date);

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedDate = date);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : (isToday
                                ? (isDark
                                ? const Color(0xFF1E2E4E)
                                : const Color(0xFFE3EDFF))
                                : Colors.transparent),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _weekdayShort(date),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF757682)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                      ? const Color(0xFFF8FAFC)
                                      : const Color(0xFF00174D)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Micro puntos indicadores de actividades
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (cHasClasses)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : primaryColor,
                                      ),
                                    ),
                                  if (cHasEvents)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  if (cHasPayments)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  isSelectedToday
                      ? l10n.todaysCoursesTitle
                      : l10n.scheduledClasses,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF00174D),
                  ),
                ),
                if (dayClasses.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? primaryColor.withValues(alpha: 0.2)
                          : const Color(0xFFE3EDFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dayClasses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            if (dayClasses.isEmpty)
              _buildEmptyCard(
                icon: Icons.event_available_outlined,
                title: isSelectedToday
                    ? l10n.noCoursesTodayTitle
                    : l10n.noClassesThisDay,
                subtitle: isSelectedToday
                    ? l10n.noCoursesTodayDesc
                    : l10n.noClassesThisDayDesc,
                isDark: isDark,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: dayClasses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, index) {
                  final course = dayClasses[index];
                  return CourseSummaryCard(
                    course: course,
                    showBilling: false,
                    onTap: () async {
                      ref.read(selectedCourseIdProvider.notifier).state =
                          course.id;
                      await context.push('/course-detail/${course.id}');
                      if (!mounted) return;
                      ref.read(studentsRevisionProvider.notifier).state++;
                      ref.invalidate(allActiveStudentsProvider);
                      ref.invalidate(coursesProvider);
                    },
                  );
                },
              ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.schoolEvents,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF00174D),
                    ),
                  ),
                ),
                if (dayEvents.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? primaryColor.withValues(alpha: 0.2)
                          : const Color(0xFFE3EDFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dayEvents.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                TextButton.icon(
                  onPressed: () => _openCreateEventDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.newEventBtn.replaceAll('+', '').trim()),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (dayEvents.isEmpty)
              _buildEmptyCard(
                icon: Icons.event_available,
                title: l10n.noSchoolEvents,
                subtitle: l10n.noSchoolEventsDesc,
                isDark: isDark,
                action: TextButton.icon(
                  onPressed: () => _openCreateEventDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.createEvent),
                ),
              )
            else
              ...dayEvents.map(
                (evt) => _buildEventCard(evt, isDark, courses, students),
              ),
            const SizedBox(height: 18),

            // Selector de Pestañas / Filtro
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('all', l10n.filterAll, isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildTabChip('events', l10n.eventsTabCount(dayEvents.length),
                      isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildTabChip(
                      'payments',
                      l10n.paymentsTabCount(dayPayments.length),
                      isDark,
                      primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // SECCIÓN: PAGOS DE CURSOS
            if (_activeTab == 'all' || _activeTab == 'payments') ...[
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: Color(0xFF00796B), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    l10n.coursePaymentsTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF00174D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dayPayments.isEmpty)
                _buildEmptyCard(
                  icon: Icons.check_circle_outline,
                  title: l10n.noDueDatesToday,
                  subtitle: l10n.noDueDatesDesc,
                  isDark: isDark,
                )
              else
                ...dayPayments.map((p) {
                  final student =
                      students.where((s) => s.id == p.studentId).firstOrNull;
                  final course =
                      courses.where((c) => c.id == p.courseId).firstOrNull;

                  return _buildPaymentCard(
                    payment: p,
                    studentName: student != null
                        ? '${student.name} ${student.lastName}'
                        : l10n.studentFallback,
                    courseName: course?.name ?? l10n.courseFallback,
                    isDark: isDark,
                  );
                }),
              const SizedBox(height: 18),
            ],

          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(
      String key, String label, bool isDark, Color primaryColor) {
    final isSel = _activeTab == key;
    return InkWell(
      onTap: () => setState(() => _activeTab = key),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSel
              ? primaryColor
              : (isDark ? const Color(0xFF151D2E) : Colors.white),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSel
                ? primaryColor
                : (isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF43474E)),
          ),
        ),
      ),
    );
  }

  ({IconData icon, Color background, Color foreground}) _eventTypeVisual(
    String type,
    bool isDark,
  ) {
    switch (type) {
      case 'project':
        return (
          icon: Icons.palette_outlined,
          background: isDark ? const Color(0xFF3B0764) : const Color(0xFFF3E8FF),
          foreground: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF7E22CE),
        );
      case 'meeting':
        return (
          icon: Icons.groups_outlined,
          background: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
          foreground: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
        );
      case 'holiday':
        return (
          icon: Icons.beach_access_outlined,
          background: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
          foreground: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
        );
      case 'special':
        return (
          icon: Icons.star_outline,
          background: isDark ? const Color(0xFF831843) : const Color(0xFFFCE7F3),
          foreground: isDark ? const Color(0xFFFBCFE8) : const Color(0xFFBE185D),
        );
      default:
        return (
          icon: Icons.assignment_outlined,
          background: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFE3EDFF),
          foreground: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1D4ED8),
        );
    }
  }

  String _eventTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'project':
        return l10n.eventTypeProject;
      case 'meeting':
        return l10n.eventTypeMeeting;
      case 'holiday':
        return l10n.eventTypeHoliday;
      case 'special':
        return l10n.eventTypeSpecial;
      default:
        return l10n.eventTypeExam;
    }
  }

  String _eventDateLabel(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    final locale = Localizations.localeOf(context).toString();
    final raw = DateFormat('EEE, d MMM y', locale).format(parsed);
    if (raw.isEmpty) return date;
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String _eventTimeLabel(CalendarEvent event) {
    final end = event.endTime;
    if (end != null && end.isNotEmpty) {
      return '${event.startTime} – $end';
    }
    return event.startTime;
  }

  Widget _eventMeta({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color muted,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: muted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    CalendarEvent event,
    bool isDark,
    List<Course> courses,
    List<Student> students,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final visual = _eventTypeVisual(event.type, isDark);
    final titleColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E2A4A);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF7B8494);
    final courseId = event.courseId;
    final course = courseId == null || courseId.isEmpty
        ? null
        : courses.where((item) => item.id == courseId).firstOrNull;
    final relatedStudents = course == null
        ? const <Student>[]
        : students.where(
            (student) => student.active && student.courseId == course.id,
          );
    final studentCount = relatedStudents.length;
    final studentLabel = course == null
        ? ''
        : '$studentCount ${studentCount == 1 ? l10n.studentSingular : l10n.studentPlural}';
    final className = course?.name ?? l10n.allCoursesGeneral;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : const Color(0xFF1E3A8A).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(visual.icon, size: 26, color: visual.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 15, color: muted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _eventDateLabel(event.date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: muted.withValues(alpha: 0.45),
                        ),
                        Icon(Icons.access_time, size: 16, color: muted),
                        const SizedBox(width: 6),
                        Text(
                          _eventTimeLabel(event),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: visual.foreground.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _eventTypeLabel(event.type, l10n).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: visual.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.deleteEvent,
                padding: EdgeInsets.zero,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                onSelected: (value) {
                  if (value != 'delete') return;
                  ref
                      .read(calendarEventsProvider.notifier)
                      .deleteEvent(event.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.eventDeleted)),
                  );
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.deleteEvent),
                  ),
                ],
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF243044)
                        : const Color(0xFFF3F5F8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_horiz, color: muted, size: 20),
                ),
              ),
            ],
          ),
          if (event.description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF3D4A63),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 12),
            child: Divider(
              height: 1,
              color: isDark
                  ? const Color(0xFF2A3850)
                  : const Color(0xFFE6EAF2),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _eventMeta(
                  icon: Icons.groups_outlined,
                  title: className,
                  subtitle: studentLabel,
                  titleColor: titleColor,
                  muted: muted,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _openShareEventDialog(context, event),
                icon: const Icon(Icons.mail_outline, size: 16),
                label: Text(
                  l10n.notifyParents,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF134E4A)
                      : const Color(0xFFE7F8FB),
                  foregroundColor: isDark
                      ? const Color(0xFF99F6E4)
                      : const Color(0xFF0E7490),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required Payment payment,
    required String studentName,
    required String courseName,
    required bool isDark,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isPaid = payment.status == PaymentStatus.paid;
    final isOverdue = payment.status == PaymentStatus.overdue;

    final badgeBg = isPaid
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD8F3DC))
        : isOverdue
        ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFDE8E8))
        : (isDark ? const Color(0xFF1E2E4E) : const Color(0xFFE3EDFF));

    final badgeTextColor = isPaid
        ? const Color(0xFF00796B)
        : isOverdue
        ? const Color(0xFFD32F2F)
        : const Color(0xFF00236F);

    final statusText = isPaid
        ? l10n.paidStatus
        : isOverdue
        ? l10n.overdueStatus
        : l10n.pendingStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF00174D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$courseName · ${Payment.formatPeriodName(payment.periodYear, payment.periodMonth, locale)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF5F6368),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(payment.amount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF00174D),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF757682)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF43474E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF757682),
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            action,
          ],
        ],
      ),
    );
  }
}
