import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/providers/courses_provider.dart';
import '../providers/calendar_events_provider.dart';

Future<void> showCreateEventSheet(
  BuildContext context, {
  DateTime? initialDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => CreateEventDialog(initialDate: initialDate),
  );
}

class CreateEventDialog extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const CreateEventDialog({
    super.key,
    this.initialDate,
  });

  @override
  ConsumerState<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends ConsumerState<CreateEventDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late String _selectedCourseId;
  String _eventType = 'exam';
  late DateTime _eventDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  String? _formError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final courses = ref.read(coursesProvider).value ?? [];
    _selectedCourseId = courses.isNotEmpty ? courses.first.id : '';
    _eventDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _toDateStr(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      setState(() => _formError = l10n.eventTitleRequired);
      return;
    }
    if (desc.isEmpty) {
      setState(() => _formError = l10n.eventDescriptionRequired);
      return;
    }

    setState(() {
      _formError = null;
      _saving = true;
    });

    await ref.read(calendarEventsProvider.notifier).addEvent(
      title: title,
      type: _eventType,
      description: desc,
      date: _toDateStr(_eventDate),
      startTime: _formatSheetTime(_startTime),
      endTime: _formatSheetTime(_endTime),
      courseId: _selectedCourseId.isEmpty ? null : _selectedCourseId,
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.eventSaved(title)),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final courses = ref.watch(coursesProvider).value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final media = MediaQuery.of(context);
    final maxHeight =
        media.size.height - media.padding.top - media.viewInsets.bottom - 8;
    final sheetColor = isDark ? const Color(0xFF151D2E) : Colors.white;
    final textPrimary = AppColors.textPrimary(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                          controller: _titleController,
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
                            (
                              id: 'exam',
                              label: l10n.eventTypeExam,
                              icon: Icons.assignment_outlined
                            ),
                            (
                              id: 'project',
                              label: l10n.eventTypeProject,
                              icon: Icons.palette_outlined
                            ),
                            (
                              id: 'meeting',
                              label: l10n.eventTypeMeeting,
                              icon: Icons.groups_outlined
                            ),
                            (
                              id: 'holiday',
                              label: l10n.eventTypeHoliday,
                              icon: Icons.beach_access_outlined
                            ),
                            (
                              id: 'special',
                              label: l10n.eventTypeSpecial,
                              icon: Icons.star_outline
                            ),
                          ].map((item) {
                            final isSel = _eventType == item.id;
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
                                if (val) setState(() => _eventType = item.id);
                              },
                              selectedColor: primaryColor,
                              backgroundColor: AppColors.surfaceLow(context),
                              side: BorderSide(
                                color: isSel
                                    ? primaryColor
                                    : AppColors.outlineVariantAdaptive(context),
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
                            initialValue: _selectedCourseId,
                            isExpanded: true,
                            decoration: _sheetInputDecoration(context),
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
                              setState(() => _selectedCourseId = val ?? '');
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        AppFieldLabel(l10n.dateLabel),
                        const SizedBox(height: 4),
                        _sheetTapField(
                          context: context,
                          icon: Icons.calendar_today_outlined,
                          value: DateFormat.yMMMEd(
                            Localizations.localeOf(context).toString(),
                          ).format(_eventDate),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _eventDate,
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _eventDate = picked);
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
                                context: context,
                                icon: Icons.access_time,
                                value: _formatSheetTime(_startTime),
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime,
                                  );
                                  if (picked == null) return;
                                  setState(() {
                                    _startTime = picked;
                                    final startMinutes =
                                        picked.hour * 60 + picked.minute;
                                    final endMinutes =
                                        _endTime.hour * 60 + _endTime.minute;
                                    if (endMinutes <= startMinutes) {
                                      final next = startMinutes + 60;
                                      _endTime = TimeOfDay(
                                        hour: (next ~/ 60) % 24,
                                        minute: next % 60,
                                      );
                                    }
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '–',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _sheetTapField(
                                context: context,
                                icon: Icons.access_time,
                                value: _formatSheetTime(_endTime),
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _endTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _endTime = picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: l10n.descriptionInstructionsLabel,
                          controller: _descController,
                          hint: l10n.descriptionHint,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_formError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
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
                              _formError!,
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
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
