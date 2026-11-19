import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/course_icon_helper.dart';
import '../models/course_model.dart';
import '../providers/courses_provider.dart';

Future<void> showDeleteCourseConfirmation({
  required BuildContext context,
  required WidgetRef ref,
  required Course course,
  bool closeParent = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF3B171A) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.iconError, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.deleteCourseConfirmTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF00174D),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteCourseConfirmBody(course.name),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF43474E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (closeParent && context.mounted) {
                Navigator.of(context).pop();
              }
              await ref.read(coursesProvider.notifier).deleteCourse(course.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.courseDeletedSuccess(course.name)),
                    backgroundColor: const Color(0xFFD32F2F),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_forever, size: 18),
            label: Text(l10n.yesDeleteCourse),
          ),
        ],
      );
    },
  );
}

class CreateCourseDialog extends ConsumerStatefulWidget {
  final Course? courseToEdit;

  const CreateCourseDialog({
    super.key,
    this.courseToEdit,
  });

  @override
  ConsumerState<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends ConsumerState<CreateCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _costController;

  late PaymentSchedule _paymentSchedule;
  late CourseType _courseType;
  late BillingFrequency _billingFrequency;
  late List<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Map<int, _CourseDayScheduleDraft> _daySchedules;
  bool _sameScheduleForAll = true;
  late String _selectedIconKey;
  bool _isSaving = false;

  static const List<int> _dayNumbers = [1, 2, 3, 4, 5, 6, 7];

  String _weekdayAbbreviation(int day) {
    const spanish = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'];
    const english = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final abbreviations = Localizations.localeOf(context).languageCode == 'en'
        ? english
        : spanish;
    return abbreviations[day - 1];
  }

  String _weekdayName(int day, AppLocalizations l10n) {
    switch (day) {
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      case 6:
        return l10n.weekdaySaturday;
      case 7:
        return l10n.weekdaySunday;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    final edit = widget.courseToEdit;

    _nameController = TextEditingController(text: edit?.name ?? '');
    _costController = TextEditingController(
      text: edit != null ? _formatCost(edit.cost) : '',
    );
    _nameController.addListener(_refreshFormState);
    _costController.addListener(_refreshFormState);

    _paymentSchedule = edit?.paymentSchedule ?? PaymentSchedule.firstHalf;
    _courseType = edit?.type ?? CourseType.group;
    _billingFrequency = edit?.billingFrequency ?? BillingFrequency.monthly;
    _selectedDays = edit != null
        ? List<int>.from(edit.classDays)
        : [1, 3]; // Default Lun & Mié
    _selectedIconKey = edit?.iconKey ?? 'robotics';

    final savedSchedules = edit?.effectiveClassSchedules ?? const [];
    _startTime = savedSchedules.isNotEmpty
        ? _parseTime(savedSchedules.first.startTime,
            const TimeOfDay(hour: 17, minute: 0))
        : const TimeOfDay(hour: 17, minute: 0);
    _endTime = savedSchedules.isNotEmpty
        ? _parseTime(
            savedSchedules.first.endTime, const TimeOfDay(hour: 18, minute: 30))
        : const TimeOfDay(hour: 18, minute: 30);
    _daySchedules = {
      for (final item in savedSchedules)
        item.weekday: _CourseDayScheduleDraft(
          startTime: _parseTime(item.startTime, _startTime),
          endTime: _parseTime(item.endTime, _endTime),
        ),
    };
    for (final day in _selectedDays) {
      _daySchedules.putIfAbsent(
        day,
        () => _CourseDayScheduleDraft(
          startTime: _startTime,
          endTime: _endTime,
        ),
      );
    }
    if (savedSchedules.length > 1) {
      _sameScheduleForAll = savedSchedules.every((item) =>
          item.startTime == savedSchedules.first.startTime &&
          item.endTime == savedSchedules.first.endTime);
    }
  }

  void _refreshFormState() {
    if (mounted) setState(() {});
  }

  bool get _isFormReady {
    final cost = double.tryParse(
      _costController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    return _nameController.text.trim().isNotEmpty && cost != null && cost > 0;
  }

  TimeOfDay _parseTime(String timeStr, TimeOfDay fallback) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPM = clean.contains('PM');
      final isAM = clean.contains('AM');
      final digits = clean.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = digits.split(':');
      if (parts.length >= 2) {
        int h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        if (isPM && h < 12) h += 12;
        if (isAM && h == 12) h = 0;
        return TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}
    return fallback;
  }

  String _formatTime12(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<TimeOfDay?> _pickTime({
    required TimeOfDay initialTime,
    required String helpText,
  }) =>
      showAppWheelTimePicker(context,
          initialTime: initialTime, helpText: helpText);


  Future<void> _pickStartTime({int? weekday}) async {
    final time = weekday == null || _sameScheduleForAll
        ? _startTime
        : _daySchedules[weekday]!.startTime;
    final picked = await _pickTime(
      initialTime: time,
      helpText: AppLocalizations.of(context)!.selectStartTime,
    );
    if (picked == null) return;
    setState(() {
      if (weekday == null || _sameScheduleForAll) {
        _startTime = picked;
      } else {
        _daySchedules[weekday]!.startTime = picked;
      }
    });
  }

  Future<void> _pickEndTime({int? weekday}) async {
    final time = weekday == null || _sameScheduleForAll
        ? _endTime
        : _daySchedules[weekday]!.endTime;
    final picked = await _pickTime(
      initialTime: time,
      helpText: AppLocalizations.of(context)!.selectEndTime,
    );
    if (picked == null) return;
    setState(() {
      if (weekday == null || _sameScheduleForAll) {
        _endTime = picked;
      } else {
        _daySchedules[weekday]!.endTime = picked;
      }
    });
  }

  void _setSameScheduleForAll(bool value) {
    setState(() {
      if (value && _selectedDays.isNotEmpty) {
        final first = _daySchedules[_selectedDays.first];
        if (first != null) {
          _startTime = first.startTime;
          _endTime = first.endTime;
        }
      }
      _sameScheduleForAll = value;
      if (!value) {
        for (final day in _selectedDays) {
          _daySchedules[day] = _CourseDayScheduleDraft(
            startTime: _startTime,
            endTime: _endTime,
          );
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectAtLeastOneDay),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final cost = double.tryParse(
      _costController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (cost == null || cost <= 0) return;

    setState(() => _isSaving = true);

    try {
      final classSchedules = _selectedDays.map((day) {
        final draft = _sameScheduleForAll
            ? _CourseDayScheduleDraft(
                startTime: _startTime,
                endTime: _endTime,
              )
            : _daySchedules[day]!;
        return CourseClassSchedule(
          weekday: day,
          startTime: _formatTime12(draft.startTime),
          endTime: _formatTime12(draft.endTime),
        );
      }).toList()
        ..sort((a, b) => a.weekday.compareTo(b.weekday));
      final startTimeStr = classSchedules.first.startTime;
      final endTimeStr = classSchedules.first.endTime;

      if (widget.courseToEdit != null) {
        // Modo Edición
        final updatedCourse = widget.courseToEdit!.copyWith(
          name: name,
          classDays: _selectedDays,
          startTime: startTimeStr,
          endTime: endTimeStr,
          classSchedules: classSchedules,
          cost: cost,
          paymentSchedule: _paymentSchedule,
          iconKey: _selectedIconKey,
          type: _courseType,
          billingFrequency: _billingFrequency,
        );

        await ref.read(coursesProvider.notifier).updateCourse(updatedCourse);

        if (mounted) {
          Navigator.of(context).pop(updatedCourse);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.courseUpdatedSuccess(name)),
              backgroundColor: AppColors.inverseSurface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Modo Creación
        final newCourse = await ref.read(coursesProvider.notifier).addCourse(
              name: name,
              classDays: _selectedDays,
              startTime: startTimeStr,
              endTime: endTimeStr,
              classSchedules: classSchedules,
              totalSessions: 32,
              cost: cost,
              capacity: _courseType == CourseType.individual ? 1 : 30,
              paymentSchedule: _paymentSchedule,
              iconKey: _selectedIconKey,
              type: _courseType,
              billingFrequency: _billingFrequency,
            );

        ref.read(selectedCourseIdProvider.notifier).state = newCourse.id;

        if (mounted) {
          Navigator.of(context).pop(newCourse);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.courseCreatedSuccess(name)),
              backgroundColor: AppColors.inverseSurface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDeleteCourse() {
    final course = widget.courseToEdit;
    if (course == null) return;
    showDeleteCourseConfirmation(
      context: context,
      ref: ref,
      course: course,
      closeParent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final isEditing = widget.courseToEdit != null;
    final titleColor = AppColors.textPrimary(context);
    final panelColor =
        isDark ? const Color(0xFF30343B) : const Color(0xFFF1F3F5);
    final panelBorder = AppColors.cardBorder(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: panelBorder,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  isEditing
                                      ? (l10n?.editCourseTitle ??
                                          'Editar curso')
                                      : (l10n?.createCourseTitle ??
                                          'Crear curso'),
                                  style: AppTextStyles.titleLarge
                                      .copyWith(color: titleColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.close_outlined,
                                      color: AppColors.iconMuted(context)),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: SizedBox(
                              width: double.infinity,
                              child: _CourseTypeSelector(
                                value: _courseType,
                                onChanged: (value) =>
                                    setState(() => _courseType = value),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Datos del curso', Icons.school_outlined,
                            AppColors.iconDefault, titleColor),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Nombre *',
                          controller: _nameController,
                          hint:
                              l10n?.courseNameHint ?? 'Ej. Inglés avanzado B2',
                          validator: (v) {
                            final name = v?.trim() ?? '';
                            if (name.isEmpty) {
                              return l10n?.courseNameRequired ??
                                  'Nombre obligatorio';
                            }
                            if (name.length < 2) {
                              return Localizations.localeOf(context)
                                          .languageCode ==
                                      'en'
                                  ? 'Enter at least 2 characters'
                                  : 'Escribe al menos 2 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        appFormLabel(
                          context,
                          l10n?.classDaysLabel ?? 'Días de clase *',
                          style: _inputLabelStyle,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: panelBorder),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Row(
                            children: [
                              for (final day in _dayNumbers)
                                Expanded(
                                  child: _buildDayChip(
                                    dayNumber: day,
                                    dayLabel: _weekdayAbbreviation(day),
                                    dayName: _weekdayName(day, l10n!),
                                    primaryColor: primaryColor,
                                    panelBorder: panelBorder,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n?.sameScheduleEveryDay ??
                                'Mismo horario todos los días',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: _sameScheduleForAll,
                          onChanged: _setSameScheduleForAll,
                        ),
                        if (_sameScheduleForAll)
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeInput(
                                  icon: Icons.schedule,
                                  label: l10n?.startTimeLabel ??
                                      'Hora de inicio *',
                                  value: _startTime,
                                  onTap: _pickStartTime,
                                  panelColor: panelColor,
                                  panelBorder: panelBorder,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTimeInput(
                                  icon: Icons.schedule,
                                  label: l10n?.endTimeLabel ?? 'Hora de fin *',
                                  value: _endTime,
                                  onTap: _pickEndTime,
                                  panelColor: panelColor,
                                  panelBorder: panelBorder,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              for (final day in _selectedDays)
                                _buildDayScheduleRow(
                                  day: day,
                                  dayName: _weekdayName(day, l10n!),
                                  panelColor: panelColor,
                                  panelBorder: panelBorder,
                                ),
                            ],
                          ),
                        const SizedBox(height: 28),
                        _sectionTitle(
                            'Cobro del curso',
                            Icons.payments_outlined,
                            AppColors.iconDefault,
                            titleColor),
                        const SizedBox(height: 12),
                        appFormLabel(context, 'Frecuencia de cobro',
                            style: _inputLabelStyle),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<BillingFrequency>(
                          value: _billingFrequency,
                          isExpanded: true,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: panelColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: BillingFrequency.perClass,
                                child: Text('Por clase / día')),
                            DropdownMenuItem(
                                value: BillingFrequency.weekly,
                                child: Text('Semanal')),
                            DropdownMenuItem(
                                value: BillingFrequency.biweekly,
                                child: Text('Quincenal')),
                            DropdownMenuItem(
                                value: BillingFrequency.monthly,
                                child: Text('Mensual')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _billingFrequency = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          label: _billingFrequency == BillingFrequency.monthly
                              ? (l10n?.monthlyCostLabel ?? 'Costo mensual (\$)')
                              : 'Precio por periodo (\$)',
                          controller: _costController,
                          hint: '45,000',
                          keyboardType: TextInputType.number,
                          inputFormatters: const [
                            _ThousandsSeparatorInputFormatter()
                          ],
                          validator: (v) {
                            final parsed = double.tryParse(
                              (v ?? '').replaceAll(RegExp(r'[^0-9.]'), ''),
                            );
                            if (parsed == null || parsed <= 0) {
                              return l10n?.required ?? 'Requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _sectionTitle(
                            l10n?.chooseIconLabel ?? 'Icono del curso',
                            Icons.palette_outlined,
                            AppColors.iconDefault,
                            titleColor),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: panelBorder),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kCourseIconCategories.map((cat) {
                              final isSelected =
                                  _selectedIconKey.toLowerCase() ==
                                      cat.key.toLowerCase();
                              return InkWell(
                                onTap: () {
                                  setState(() => _selectedIconKey = cat.key);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark
                                            ? const Color(0xFF1E293B)
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : (isDark
                                              ? const Color(0xFF334155)
                                              : AppColors.surfaceContainerHigh),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    size: 22,
                                    color: isSelected
                                        ? AppColors.iconOnPrimary
                                        : AppColors.iconDefault,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStickyFooter(
                  context: context,
                  isEditing: isEditing,
                  primaryColor: primaryColor,
                  titleColor: titleColor,
                  cancelLabel: l10n?.cancel ?? 'Cancelar',
                  actionLabel: isEditing
                      ? (l10n?.save ?? 'Guardar')
                      : (l10n?.create ?? 'Crear'),
                  deleteLabel: l10n?.deleteCourseBtn ?? 'Eliminar curso',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyFooter({
    required BuildContext context,
    required bool isEditing,
    required Color primaryColor,
    required Color titleColor,
    required String cancelLabel,
    required String actionLabel,
    required String deleteLabel,
  }) {
    final enabled = _isFormReady && !_isSaving;
    final disabledColor = AppColors.outlineVariantAdaptive(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: enabled ? primaryColor : disabledColor,
      disabledBackgroundColor: disabledColor,
      foregroundColor: enabled ? Colors.white : titleColor,
      disabledForegroundColor: AppColors.textSecondary(context),
      shape: const StadiumBorder(),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.cardBorder(context)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: isEditing
                ? ElevatedButton(
                    onPressed: enabled ? _submit : null,
                    style: buttonStyle,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(actionLabel),
                  )
                : ElevatedButton.icon(
                    onPressed: enabled ? _submit : null,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(actionLabel),
                    style: buttonStyle,
                  ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: isEditing
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (isEditing)
                TextButton(
                  onPressed: _isSaving ? null : _confirmDeleteCourse,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(deleteLabel),
                )
              else
                const SizedBox.shrink(),
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(cancelLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip({
    required int dayNumber,
    required String dayLabel,
    required String dayName,
    required Color primaryColor,
    required Color panelBorder,
  }) {
    final isSelected = _selectedDays.contains(dayNumber);

    return Semantics(
      button: true,
      selected: isSelected,
      label: dayName,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNumber);
                _daySchedules.remove(dayNumber);
              } else {
                _selectedDays.add(dayNumber);
                _selectedDays.sort();
                _daySchedules[dayNumber] = _CourseDayScheduleDraft(
                  startTime: _startTime,
                  endTime: _endTime,
                );
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryColor : panelBorder,
              ),
            ),
            child: Text(
              dayLabel,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : AppColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput({
    required IconData icon,
    required String label,
    required TimeOfDay value,
    required VoidCallback onTap,
    required Color panelColor,
    required Color panelBorder,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: panelBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.iconDefault),
                const SizedBox(width: 4),
                Flexible(
                  child: appFormLabel(
                    context,
                    label,
                    style: _inputLabelStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime12(value),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayScheduleRow({
    required int day,
    required String dayName,
    required Color panelColor,
    required Color panelBorder,
  }) {
    final schedule = _daySchedules[day]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              _weekdayAbbreviation(day),
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
              semanticsLabel: dayName,
            ),
          ),
          Expanded(
            child: _buildCompactTimeButton(
              icon: Icons.schedule,
              value: schedule.startTime,
              label: dayName,
              panelColor: panelColor,
              panelBorder: panelBorder,
              onTap: () => _pickStartTime(weekday: day),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCompactTimeButton(
              icon: Icons.schedule,
              value: schedule.endTime,
              label: dayName,
              panelColor: panelColor,
              panelBorder: panelBorder,
              onTap: () => _pickEndTime(weekday: day),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimeButton({
    required IconData icon,
    required TimeOfDay value,
    required String label,
    required Color panelColor,
    required Color panelBorder,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: '$label · ${_formatTime12(value)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: panelBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.iconDefault),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatTime12(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _inputLabelStyle {
    final style = appInputLabelStyle(context);
    if (Theme.of(context).brightness != Brightness.dark) return style;
    return style.copyWith(color: AppColors.textPrimary(context));
  }

  Widget _sectionTitle(
      String title, IconData icon, Color color, Color foreground) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCost(num amount) {
    return _ThousandsSeparatorInputFormatter.formatDigits(
      amount.toStringAsFixed(0),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final fillColor =
        isDark ? const Color(0xFF30343B) : const Color(0xFFF1F3F5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appFormLabel(
          context,
          label,
          required: required,
          style: _inputLabelStyle,
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization:
              textCapitalization ?? appDefaultTextCapitalization(keyboardType),
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _CourseDayScheduleDraft {
  TimeOfDay startTime;
  TimeOfDay endTime;

  _CourseDayScheduleDraft({
    required this.startTime,
    required this.endTime,
  });
}

class _CourseTypeSelector extends StatelessWidget {
  final CourseType value;
  final ValueChanged<CourseType> onChanged;

  const _CourseTypeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isGroupSelected = value == CourseType.group;

    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
                isGroupSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _option(
                type: CourseType.group,
                label: 'Curso grupal',
                icon: Icons.groups_outlined,
                selected: isGroupSelected,
              ),
              _option(
                type: CourseType.individual,
                label: 'Individual',
                icon: Icons.person_outline,
                selected: !isGroupSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _option({
    required CourseType type,
    required String label,
    required IconData icon,
    required bool selected,
  }) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: () => onChanged(type),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox.expand(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.black),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const _ThousandsSeparatorInputFormatter();

  static String formatDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = formatDigits(digits);
    final selectionEnd = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text
        .substring(0, selectionEnd)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    var cursor = 0;
    var seen = 0;
    while (cursor < formatted.length && seen < digitsBeforeCursor) {
      if (RegExp(r'\d').hasMatch(formatted[cursor])) seen++;
      cursor++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}
