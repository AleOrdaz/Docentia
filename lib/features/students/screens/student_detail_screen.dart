import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../providers/students_provider.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  void _openWhatsApp(String phone, String studentName, String tutorName) async {
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El alumno no tiene registrado teléfono de tutor')),
      );
      return;
    }

    final message =
        'Hola $tutorName, le escribo desde Docentia para informarle sobre el progreso de su tutorado/a $studentName.';
    final success = await WhatsAppService.openWhatsApp(phone: phone, message: message);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp en este dispositivo')),
      );
    }
  }

  void _confirmDeactivate(BuildContext context, String studentName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Dar de baja al alumno?'),
        content: Text(
          'El alumno $studentName dejará de figurar en la lista activa del curso, pero sus asistencias y pagos se conservarán intactos.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final course = ref.read(selectedCourseProvider);
              final courseId = course?.id ?? 'course-1';

              await ref
                  .read(studentsForCourseProvider(courseId).notifier)
                  .deactivateStudent(widget.studentId);

              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alumno dado de baja. Historial conservado.'),
                  ),
                );
              }
            },
            child: const Text('Confirmar Baja'),
          ),
        ],
      ),
    );
  }

  void _showConfirmPaymentDialog({
    required BuildContext context,
    required Payment payment,
    required String studentName,
    required String courseName,
    required String courseId,
  }) {
    final now = DateTime.now();
    final todayFormatted = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 24),
            const SizedBox(width: 8),
            const Text('Confirmar Pago'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revisa los datos del pago que vas a registrar:', style: AppTextStyles.bodySmall),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPaymentSummaryRow('Alumno:', studentName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow('Curso:', courseName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow('Mensualidad:', payment.period),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow('Fecha de pago:', todayFormatted),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monto a pagar:', style: AppTextStyles.titleSmall),
                      Text(
                        formatCurrency(payment.amount),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(paymentsForCourseProvider(courseId).notifier)
                  .confirmPayment(payment.id, paidAmount: payment.amount, paidDate: now);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
                        const SizedBox(width: 8),
                        Text('Pago de ${formatCurrency(payment.amount)} confirmado para $studentName'),
                      ],
                    ),
                    backgroundColor: AppColors.inverseSurface,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(selectedCourseProvider);
    final courseId = course?.id ?? 'course-1';
    final primaryColor = Theme.of(context).colorScheme.primary;

    final studentsAsync = ref.watch(studentsForCourseProvider(courseId));
    final student = studentsAsync.value
        ?.where((s) => s.id == widget.studentId)
        .firstOrNull;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ficha del Alumno')),
        body: const Center(child: Text('Alumno no encontrado')),
      );
    }

    final statsAsync = ref.watch(
      studentStatsProvider(StudentStatsParam(studentId: student.id, courseId: courseId)),
    );

    final paymentsAsync = ref.watch(
      studentPaymentsProvider((studentId: student.id, courseId: courseId)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Ficha del Alumno', style: AppTextStyles.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Tarjeta de identidad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Row(
                children: [
                  if (student.avatarUrl != null && student.avatarUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        student.avatarUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitials(student.initials, primaryColor),
                      ),
                    )
                  else
                    _buildInitials(student.initials, primaryColor),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('${student.age} años', style: AppTextStyles.bodySmall),
                            const SizedBox(width: 6),
                            Text('•', style: AppTextStyles.bodySmall),
                            const SizedBox(width: 6),
                            Text(
                              course?.name ?? 'Curso',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: student.active
                                ? AppColors.secondaryFixed.withValues(alpha: 0.3)
                                : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            student.active ? 'Alumno Regular' : 'Dado de Baja',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: student.active ? AppColors.secondary : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Botones de acción (WhatsApp + Baja)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(
                      student.tutorPhone,
                      student.fullName,
                      student.tutorName,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('WhatsApp Tutor', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _confirmDeactivate(context, student.fullName),
                  icon: const Icon(Icons.person_remove, color: AppColors.error),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estadísticas dinámicas de asistencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.how_to_reg, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text('Asistencia del Alumno', style: AppTextStyles.titleSmall),
                        ],
                      ),
                      Text('Registro en tiempo real', style: AppTextStyles.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),

                  statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatBox('Clases', stats.totalClasses.toString())),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox('Asistencias', stats.presents.toString(), color: AppColors.secondary)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox('Faltas', stats.absences.toString(), color: AppColors.error)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox('Porcentaje', '${stats.percentage}%', color: primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: (stats.percentage / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error calculando métricas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Datos del Tutor
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.family_restroom, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Datos del Tutor / Apoderado', style: AppTextStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTutorField('Nombre', student.tutorName),
                  _buildTutorField('Teléfono Móvil', student.tutorPhone),
                  _buildTutorField('Correo Electrónico', student.tutorEmail),
                  if (student.secondaryPhone != null && student.secondaryPhone!.isNotEmpty)
                    _buildTutorField('Teléfono Secundario', student.secondaryPhone!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cuotas y Mensualidades con acción clara de Confirmar Pago
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments_outlined, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text('Cuotas y Mensualidades', style: AppTextStyles.titleSmall),
                        ],
                      ),
                      if (course != null)
                        InkWell(
                          onTap: () async {
                            await ref.read(paymentsForCourseProvider(courseId).notifier).generateFeeForStudent(
                              studentId: student.id,
                              cost: course.cost,
                              schedule: course.paymentSchedule,
                            );
                          },
                          child: Text(
                            '+ Nueva Cuota',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  paymentsAsync.when(
                    data: (payments) {
                      if (payments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                'Aún no hay cuotas emitidas para este alumno.',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              if (course != null)
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    await ref.read(paymentsForCourseProvider(courseId).notifier).generateFeeForStudent(
                                      studentId: student.id,
                                      cost: course.cost,
                                      schedule: course.paymentSchedule,
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Generar mensualidad actual'),
                                ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: payments.map((p) {
                          final isPaid = p.status == PaymentStatus.paid;
                          final isUpcoming = p.status == PaymentStatus.upcoming;
                          final isOverdue = p.status == PaymentStatus.overdue;

                          Color badgeBg;
                          Color badgeFg;
                          if (isPaid) {
                            badgeBg = AppColors.secondaryFixed;
                            badgeFg = AppColors.onSecondaryContainer;
                          } else if (isUpcoming) {
                            badgeBg = AppColors.warningContainer;
                            badgeFg = AppColors.onWarningContainer;
                          } else if (isOverdue) {
                            badgeBg = AppColors.errorContainer;
                            badgeFg = AppColors.onErrorContainer;
                          } else {
                            badgeBg = AppColors.surfaceContainer;
                            badgeFg = AppColors.onSurfaceVariant;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUpcoming
                                    ? AppColors.warning.withValues(alpha: 0.5)
                                    : isOverdue
                                    ? AppColors.error.withValues(alpha: 0.4)
                                    : Colors.transparent,
                                width: isUpcoming || isOverdue ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.period, style: AppTextStyles.titleSmall),
                                        Text('Vence: ${p.dueDate}', style: AppTextStyles.bodySmall),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        p.status.displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: badgeFg,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatCurrency(p.amount),
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? AppColors.secondary : AppColors.onSurface,
                                      ),
                                    ),
                                    if (!isPaid)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showConfirmPaymentDialog(
                                            context: context,
                                            payment: p,
                                            studentName: student.fullName,
                                            courseName: course?.name ?? 'Curso',
                                            courseId: courseId,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Confirmar pago'),
                                      )
                                    else
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: AppColors.secondary, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Pagado',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar pagos'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String initials, Color primaryColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color ?? AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
