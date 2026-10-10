import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/course_icon_helper.dart';
import '../models/course_model.dart';
import '../providers/courses_provider.dart';

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
  late final TextEditingController _sessionsController;
  late final TextEditingController _costController;
  late final TextEditingController _capacityController;

  late PaymentSchedule _paymentSchedule;
  late List<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedIconKey;
  bool _isSaving = false;

  static const List<(int, String)> _allWeekDays = [
    (1, 'Lunes'),
    (2, 'Martes'),
    (3, 'Miércoles'),
    (4, 'Jueves'),
    (5, 'Viernes'),
    (6, 'Sábado'),
    (7, 'Domingo'),
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.courseToEdit;

    _nameController = TextEditingController(text: edit?.name ?? '');
    _sessionsController =
        TextEditingController(text: edit != null ? edit.totalSessions.toString() : '32');
    _costController =
        TextEditingController(text: edit != null ? edit.cost.toStringAsFixed(0) : '45000');
    _capacityController =
        TextEditingController(text: edit != null ? edit.capacity.toString() : '30');

    _paymentSchedule = edit?.paymentSchedule ?? PaymentSchedule.firstHalf;
    _selectedDays = edit != null ? List<int>.from(edit.classDays) : [1, 3]; // Default Lun & Mié
    _selectedIconKey = edit?.iconKey ?? 'robotics';

    _startTime = edit != null ? _parseTime(edit.startTime, const TimeOfDay(hour: 17, minute: 0)) : const TimeOfDay(hour: 17, minute: 0);
    _endTime = edit != null ? _parseTime(edit.endTime, const TimeOfDay(hour: 18, minute: 30)) : const TimeOfDay(hour: 18, minute: 30);
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
    _sessionsController.dispose();
    _costController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Seleccionar hora de inicio',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: 'Seleccionar hora de finalización',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos un día de clase.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final totalSessions = int.tryParse(_sessionsController.text) ?? 32;
      final cost = double.tryParse(_costController.text) ?? 45000.0;
      final capacity = int.tryParse(_capacityController.text) ?? 30;
      final startTimeStr = _formatTime12(_startTime);
      final endTimeStr = _formatTime12(_endTime);

      if (widget.courseToEdit != null) {
        // Modo Edición
        final updatedCourse = widget.courseToEdit!.copyWith(
          name: name,
          classDays: _selectedDays,
          startTime: startTimeStr,
          endTime: endTimeStr,
          totalSessions: totalSessions,
          duration: '$totalSessions sesiones',
          cost: cost,
          capacity: capacity,
          paymentSchedule: _paymentSchedule,
          iconKey: _selectedIconKey,
        );

        await ref.read(coursesProvider.notifier).updateCourse(updatedCourse);

        if (mounted) {
          Navigator.of(context).pop(updatedCourse);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Curso "$name" actualizado con éxito'),
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
          totalSessions: totalSessions,
          cost: cost,
          capacity: capacity,
          paymentSchedule: _paymentSchedule,
          iconKey: _selectedIconKey,
        );

        ref.read(selectedCourseIdProvider.notifier).state = newCourse.id;

        if (mounted) {
          Navigator.of(context).pop(newCourse);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Curso "$name" creado con éxito'),
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isEditing = widget.courseToEdit != null;

    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isEditing ? Icons.edit_note : Icons.school,
                              color: primaryColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Editar Curso' : 'Crear Curso',
                            style: AppTextStyles.titleLarge,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nombre del curso
                  _buildField(
                    label: 'Nombre del Curso *',
                    controller: _nameController,
                    hint: 'Ej. Inglés Avanzado B2',
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nombre obligatorio' : null,
                  ),
                  const SizedBox(height: 14),

                  // Duración (Sesiones) y Capacidad
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'Duración (Sesiones)',
                          controller: _sessionsController,
                          hint: '32',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildField(
                          label: 'Capacidad máx.',
                          controller: _capacityController,
                          hint: '30',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SECCIÓN: Días de clase (con Checkboxes para los 7 días)
                  Text(
                    'Días de clase',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona los días en que se imparte el curso:',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      children: [
                        for (int i = 0; i < _allWeekDays.length; i += 2)
                          Row(
                            children: [
                              Expanded(
                                child: _buildDayCheckbox(
                                  dayNumber: _allWeekDays[i].$1,
                                  dayName: _allWeekDays[i].$2,
                                  primaryColor: primaryColor,
                                ),
                              ),
                              if (i + 1 < _allWeekDays.length)
                                Expanded(
                                  child: _buildDayCheckbox(
                                    dayNumber: _allWeekDays[i + 1].$1,
                                    dayName: _allWeekDays[i + 1].$2,
                                    primaryColor: primaryColor,
                                  ),
                                )
                              else
                                const Spacer(),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SECCIÓN: Horario de clase (Inicio y Fin independientes)
                  Text(
                    'Horario de clase',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configura la hora de inicio y de finalización:',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Hora de inicio
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.surfaceContainer),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule, size: 14, color: primaryColor),
                                    const SizedBox(width: 4),
                                    Text('Inicio', style: AppTextStyles.labelSmall),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime12(_startTime),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Hora de finalización
                      Expanded(
                        child: InkWell(
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.surfaceContainer),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined, size: 14, color: primaryColor),
                                    const SizedBox(width: 4),
                                    Text('Fin', style: AppTextStyles.labelSmall),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime12(_endTime),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Costo
                  _buildField(
                    label: 'Costo mensual (\$)',
                    controller: _costController,
                    hint: '45000',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Vencimiento de cuota
                  Text('Fecha de Pago', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('1ra Quincena (Día 15)'),
                          selected: _paymentSchedule == PaymentSchedule.firstHalf,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: _paymentSchedule == PaymentSchedule.firstHalf
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _paymentSchedule = PaymentSchedule.firstHalf);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Fin de Mes (Día 30)'),
                          selected: _paymentSchedule == PaymentSchedule.endOfMonth,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: _paymentSchedule == PaymentSchedule.endOfMonth
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _paymentSchedule = PaymentSchedule.endOfMonth);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SECCIÓN: Icono del curso
                  Text(
                    'Icono del curso',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona el icono representativo de la materia:',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kCourseIconCategories.map((cat) {
                        final isSelected =
                            _selectedIconKey.toLowerCase() == cat.key.toLowerCase();
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedIconKey = cat.key);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : AppColors.surfaceContainerHigh,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(isEditing ? 'Guardar Cambios' : 'Crear Curso'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCheckbox({
    required int dayNumber,
    required String dayName,
    required Color primaryColor,
  }) {
    final isSelected = _selectedDays.contains(dayNumber);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDays.remove(dayNumber);
          } else {
            _selectedDays.add(dayNumber);
            _selectedDays.sort();
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              activeColor: primaryColor,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    if (!_selectedDays.contains(dayNumber)) {
                      _selectedDays.add(dayNumber);
                      _selectedDays.sort();
                    }
                  } else {
                    _selectedDays.remove(dayNumber);
                  }
                });
              },
            ),
            const SizedBox(width: 4),
            Text(
              dayName,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
