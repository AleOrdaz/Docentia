import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/providers/students_provider.dart';
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

  static const _daysOfWeekNames = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom'
  ];

  static const _monthsNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

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

  // --- Modal para Crear Nuevo Evento ---
  void _openCreateEventDialog(BuildContext context) {
    final coursesAsync = ref.read(coursesProvider);
    final courses = coursesAsync.value ?? [];

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final emailsController = TextEditingController();

    String selectedCourseId = courses.isNotEmpty ? courses.first.id : '';
    String eventType = 'exam';
    DateTime eventDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);
    String? formError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
            final primaryColor = Theme.of(modalCtx).colorScheme.primary;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151D2E) : Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
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
                            Icon(Icons.event_note,
                                color: primaryColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Nuevo Evento Escolar',
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
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFD32F2F), size: 16),
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
                    ],
                    const SizedBox(height: 14),

                    // Título
                    _buildTextField(
                      label: 'Título del Evento *',
                      controller: titleController,
                      hint: 'Ej. Primer Examen Parcial / Entrega de Proyectos',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Tipo de evento
                    Text(
                      'Tipo de Actividad',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF43474E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ('exam', 'Examen', Icons.assignment_outlined),
                        ('project', 'Proyecto', Icons.palette_outlined),
                        ('meeting', 'Reunión Apoderados', Icons.groups_outlined),
                        ('holiday', 'Día Festivo', Icons.beach_access_outlined),
                        ('special', 'Especial', Icons.star_outline),
                      ].map((item) {
                        final isSel = eventType == item.$1;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.$3,
                                  size: 14,
                                  color: isSel ? Colors.white : primaryColor),
                              const SizedBox(width: 4),
                              Text(item.$2),
                            ],
                          ),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => eventType = item.$1);
                          },
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Curso relacionado
                    if (courses.isNotEmpty) ...[
                      Text(
                        'Curso Asociado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF43474E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCourseId,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('General / Todos los Cursos'),
                              ),
                              ...courses.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              )),
                            ],
                            onChanged: (val) {
                              setModalState(
                                      () => selectedCourseId = val ?? '');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Fecha y Horario
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF43474E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Horario',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF43474E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final s = await showTimePicker(
                                    context: modalCtx,
                                    initialTime: startTime,
                                  );
                                  if (s != null) {
                                    setModalState(() => startTime = s);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Ubicación
                    _buildTextField(
                      label: 'Ubicación / Salón / Enlace (opcional)',
                      controller: locationController,
                      hint: 'Ej. Aula 3B, Laboratorio o Google Meet',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Descripción
                    _buildTextField(
                      label: 'Descripción / Instrucciones *',
                      controller: descController,
                      hint:
                      'Detalles de la actividad, temas a evaluar o materiales requeridos...',
                      maxLines: 3,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Correos adicionales
                    _buildTextField(
                      label: 'Correos adicionales de tutores (opcional)',
                      controller: emailsController,
                      hint: 'apoderado@ejemplo.com, direccion@colegio.edu',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // Botón Guardar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(modalCtx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final desc = descController.text.trim();

                            if (title.isEmpty) {
                              setModalState(() => formError =
                              'El título del evento es obligatorio.');
                              return;
                            }
                            if (desc.isEmpty) {
                              setModalState(() => formError =
                              'Por favor ingresa una descripción para el evento.');
                              return;
                            }

                            final manualEmails = emailsController.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();

                            final dateStr = _toDateStr(eventDate);
                            final startTimeStr =
                                '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                            final endTimeStr =
                                '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

                            await ref
                                .read(calendarEventsProvider.notifier)
                                .addEvent(
                              title: title,
                              description: desc,
                              date: dateStr,
                              startTime: startTimeStr,
                              endTime: endTimeStr,
                              location: locationController.text.trim(),
                              emailRecipients: manualEmails,
                            );

                            if (mounted) {
                              Navigator.of(modalCtx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Evento "$title" registrado en el calendario'),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Guardar Evento'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    final authState = ref.read(authProvider);
    final teacherName = authState.teacher?.name ?? 'Profesor Titular';
    final allStudents = ref.read(allActiveStudentsProvider).value ?? [];

    final tutorEmails = allStudents
        .map((s) => s.tutorEmail)
        .where((e) => e.trim().isNotEmpty && e.contains('@'))
        .toSet()
        .toList();

    final allRecipients = {...tutorEmails, ...event.emailRecipients}.toList();

    final subject = '[Docentia] Aviso Escolar: ${event.title} (${event.date})';
    final body = '''Estimados Padres de Familia y Tutores:

Por medio del presente aviso escolar, les informamos de la siguiente actividad programada en Docentia:
• Evento: ${event.title}
• Fecha: ${event.date}
• Horario: ${event.startTime}${event.endTime != null && event.endTime!.isNotEmpty ? ' - ${event.endTime}' : ''}${event.location != null && event.location!.isNotEmpty ? '\n• Ubicación: ${event.location}' : ''}
• Descripción: ${event.description}

Agradecemos su valioso apoyo y puntual acompañamiento.

Atentamente,
$teacherName
Docentia - Plataforma Académica''';

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
                        'Enviar Evento a Padres',
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
                        'Se preparará el correo para ${allRecipients.length} tutores con copia oculta (BCC) protegiendo su privacidad.',
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
                      'Asunto: $subject',
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
                          const SnackBar(
                            content: Text('Aviso copiado al portapapeles'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copiar Texto',
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
                              const SnackBar(
                                content: Text(
                                    'No se encontró cliente de correo instalado. Mensaje copiado.'),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Abrir Correo',
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF43474E),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

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

    // 1. Clases activas programadas en el día
    final dayCourses = courses
        .where((c) => c.active && c.isClassDay(_selectedDate))
        .toList();

    // 2. Eventos escolares registrados en la fecha
    final dayEvents =
    allEvents.where((e) => e.date == selectedDateStr).toList();

    // 3. Pagos de cursos vencidos o programados para la fecha
    final dayPayments =
    allPayments.where((p) => p.dueDate == selectedDateStr).toList();

    final is1stOr10th =
        _selectedDate.day == 1 || _selectedDate.day == 10;
    final isLastDay = DateTime(
        _selectedDate.year, _selectedDate.month + 1, 0)
        .day ==
        _selectedDate.day;

    final generalScheduleCourses = courses.where((c) {
      if (!c.active) return false;
      if (c.paymentSchedule == PaymentSchedule.firstHalf && is1stOr10th) {
        return true;
      }
      if (c.paymentSchedule == PaymentSchedule.endOfMonth && isLastDay) {
        return true;
      }
      return false;
    }).toList();

    // Indicadores para los días de la semana
    bool hasClasses(DateTime d) =>
        courses.any((c) => c.active && c.isClassDay(d));
    bool hasEvents(DateTime d) =>
        allEvents.any((e) => e.date == _toDateStr(d));
    bool hasPayments(DateTime d) {
      final ds = _toDateStr(d);
      if (allPayments.any((p) => p.dueDate == ds)) return true;
      final isFirst = d.day == 1 || d.day == 10;
      final isLast = DateTime(d.year, d.month + 1, 0).day == d.day;
      return courses.any((c) =>
      c.active &&
          ((c.paymentSchedule == PaymentSchedule.firstHalf && isFirst) ||
              (c.paymentSchedule == PaymentSchedule.endOfMonth && isLast)));
    }

    return Scaffold(
      extendBody: true,
      backgroundColor:
      isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Calendario de Clases y Eventos',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Nuevo Evento',
            icon: Icon(Icons.add_circle, color: primaryColor, size: 28),
            onPressed: () => _openCreateEventDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        '${_monthsNames[_selectedDate.month - 1]} ${_selectedDate.year}',
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
                                _daysOfWeekNames[date.weekday - 1],
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
                                            : const Color(0xFF3B82F6),
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

            // Selector de Pestañas / Filtro
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('all', 'Todos', isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildTabChip('classes', 'Clases (${dayCourses.length})',
                      isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildTabChip('events', 'Eventos (${dayEvents.length})',
                      isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildTabChip(
                      'payments',
                      'Pagos (${dayPayments.length + generalScheduleCourses.length})',
                      isDark,
                      primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // SECCIÓN: EVENTOS ESCOLARES
            if (_activeTab == 'all' || _activeTab == 'events') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event, color: primaryColor, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Eventos Escolares',
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
                  TextButton.icon(
                    onPressed: () => _openCreateEventDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nuevo Evento',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dayEvents.isEmpty)
                _buildEmptyCard(
                  icon: Icons.event_available,
                  title: 'Sin eventos escolares registrados',
                  subtitle:
                  'Puedes agregar exámenes, reuniones de apoderados o actividades con el botón "+ Nuevo Evento".',
                  isDark: isDark,
                  action: TextButton.icon(
                    onPressed: () => _openCreateEventDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Crear Evento'),
                  ),
                )
              else
                ...dayEvents.map((evt) => _buildEventCard(evt, isDark, primaryColor)),
              const SizedBox(height: 18),
            ],

            // SECCIÓN: PAGOS DE CURSOS
            if (_activeTab == 'all' || _activeTab == 'payments') ...[
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: Color(0xFF00796B), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Pagos y Cuotas de Cursos',
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
              if (dayPayments.isEmpty && generalScheduleCourses.isEmpty)
                _buildEmptyCard(
                  icon: Icons.check_circle_outline,
                  title: 'Sin vencimientos de cuotas hoy',
                  subtitle:
                  'No hay pagos con fecha límite programada para este día.',
                  isDark: isDark,
                )
              else ...[
                // Cuotas individuales registradas
                ...dayPayments.map((p) {
                  final student =
                      students.where((s) => s.id == p.studentId).firstOrNull;
                  final course =
                      courses.where((c) => c.id == p.courseId).firstOrNull;

                  return _buildPaymentCard(
                    payment: p,
                    studentName: student != null
                        ? '${student.name} ${student.lastName}'
                        : 'Alumno',
                    courseName: course?.name ?? 'Curso',
                    isDark: isDark,
                  );
                }),
                // Recordatorio de cronograma de cobro general
                ...generalScheduleCourses.map((c) => _buildGeneralScheduleCard(
                  course: c,
                  isDark: isDark,
                  primaryColor: primaryColor,
                )),
              ],
              const SizedBox(height: 18),
            ],

            // SECCIÓN: CLASES DEL DÍA
            if (_activeTab == 'all' || _activeTab == 'classes') ...[
              Row(
                children: [
                  Icon(Icons.school_outlined, color: primaryColor, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Clases Programadas',
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
              if (dayCourses.isEmpty)
                _buildEmptyCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'No hay clases programadas para este día',
                  subtitle:
                  'Selecciona otro día en el calendario semanal para consultar los horarios.',
                  isDark: isDark,
                )
              else
                ...dayCourses.map((course) => _buildCourseCard(
                  course: course,
                  isDark: isDark,
                  primaryColor: primaryColor,
                )),
              const SizedBox(height: 24),
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

  Widget _buildEventCard(
      CalendarEvent event, bool isDark, Color primaryColor) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF00174D),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFD32F2F), size: 18),
                tooltip: 'Eliminar Evento',
                onPressed: () {
                  ref
                      .read(calendarEventsProvider.notifier)
                      .deleteEvent(event.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evento escolar eliminado')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Color(0xFF757682)),
              const SizedBox(width: 4),
              Text(
                '${event.startTime}${event.endTime != null && event.endTime!.isNotEmpty ? ' - ${event.endTime}' : ''}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
              ),
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF757682)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location!,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF5F6368)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF43474E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _openShareEventDialog(context, event),
                icon: const Icon(Icons.mail_outline, size: 16),
                label: const Text('Avisar a Padres',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE0F2FE),
                  foregroundColor: const Color(0xFF0369A1),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
        ? 'Pagado'
        : isOverdue
        ? 'Atrasado'
        : 'Pendiente';

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
                  '$courseName · ${payment.period}',
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

  Widget _buildGeneralScheduleCard({
    required Course course,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E273A) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.date_range,
                color: Color(0xFF16A34A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recordatorio de Cuota: ${course.name}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fecha de cobro establecida: ${course.paymentSchedule == PaymentSchedule.firstHalf ? "Inicio de mes (Día 1-10)" : "Fin de mes (Día 30)"} · Cuota: ${formatCurrency(course.cost)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required Course course,
    required bool isDark,
    required Color primaryColor,
  }) {
    final iconData = getCourseIcon(course.iconKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFE3EDFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, size: 24, color: primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF00174D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 13, color: Color(0xFF757682)),
                    const SizedBox(width: 4),
                    Text(
                      course.startTime.isNotEmpty && course.endTime.isNotEmpty
                          ? '${course.startTime} - ${course.endTime}'
                          : course.schedule,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              ref.read(selectedCourseIdProvider.notifier).state = course.id;
              context.push('/course-detail/${course.id}');
            },
            style: FilledButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF1E2E4E)
                  : const Color(0xFFE3EDFF),
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: const StadiumBorder(),
            ),
            child: const Text('Asistencia',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
