import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../students/models/student_model.dart';
import '../models/attendance_model.dart';

class StudentAttendanceTile extends StatelessWidget {
  final Student? student;
  final String? name;
  final int? age;
  final AttendanceStatus? status;
  final String? note;
  final ValueChanged<AttendanceStatus>? onStatusChanged;
  final ValueChanged<String>? onNoteChanged;
  final VoidCallback? onTap;
  final bool isEditable;

  // Parámetros de compatibilidad previa
  final int? attendancePct;
  final String? imageUrl;
  final String? initials;
  final String? medicalNote;
  final bool? isPresent;
  final bool isPending;
  final VoidCallback? onPresentPressed;
  final VoidCallback? onAbsentPressed;
  final VoidCallback? onTapDetail;

  const StudentAttendanceTile({
    super.key,
    this.student,
    this.name,
    this.age,
    this.status,
    this.note,
    this.onStatusChanged,
    this.onNoteChanged,
    this.onTap,
    this.isEditable = true,
    this.attendancePct,
    this.imageUrl,
    this.initials,
    this.medicalNote,
    this.isPresent,
    this.isPending = false,
    this.onPresentPressed,
    this.onAbsentPressed,
    this.onTapDetail,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = student?.fullName ?? name ?? '';
    final displayAge = student?.age ?? age ?? 0;
    final displayImageUrl = student?.avatarUrl ?? imageUrl;
    final displayInitials = student?.initials ??
        initials ??
        (displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'AL');
    final displayNote = (note != null && note!.isNotEmpty)
        ? note
        : (student?.medicalNote ?? medicalNote);

    final effectiveTap = onTap ?? onTapDetail;

    final AttendanceStatus? effectiveStatus = status ??
        (isPresent != null
            ? (isPresent! ? AttendanceStatus.present : AttendanceStatus.absent)
            : null);

    final bool isMarkedPresent = effectiveStatus == AttendanceStatus.present;
    final bool isMarkedAbsent = effectiveStatus == AttendanceStatus.absent;
    final bool isMarkedExcused = effectiveStatus == AttendanceStatus.excused;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila superior: Avatar, Info, Chevron
          InkWell(
            onTap: effectiveTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                // Avatar
                if (displayImageUrl != null && displayImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      displayImageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildInitials(displayInitials, displayName),
                    ),
                  )
                else
                  _buildInitials(displayInitials, displayName),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (displayAge > 0) ...[
                            Text('$displayAge años', style: AppTextStyles.bodySmall),
                            const SizedBox(width: 6),
                            Text('•', style: AppTextStyles.bodySmall),
                            const SizedBox(width: 6),
                          ],
                          if (displayNote != null && displayNote.isNotEmpty)
                            Flexible(
                              child: Text(
                                displayNote,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else if (isPending || effectiveStatus == null)
                            Text(
                              'Sin marcar',
                              style: AppTextStyles.bodySmall,
                            )
                          else
                            Text(
                              '${attendancePct ?? 90}% asist.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                  onPressed: effectiveTap,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Fila inferior: Estado / Justificación + Toggle Segmentado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (displayNote != null && displayNote.isNotEmpty)
                InkWell(
                  onTap: isEditable ? () => _openNoteDialog(context, displayName) : null,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isMarkedExcused
                          ? AppColors.onSurfaceVariant
                          : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description,
                          size: 14,
                          color: isMarkedExcused
                              ? AppColors.onSurfaceVariant
                              : AppColors.onErrorContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMarkedExcused ? 'Justificado' : 'Justificar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isMarkedExcused
                                ? AppColors.onSurfaceVariant
                                : AppColors.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isPending || effectiveStatus == null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pendiente',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                )
              else
                Text(
                  'Asistencia hoy:',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                ),

              // Segmented Buttons [Presente | Falta]
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón Presente
                    InkWell(
                      onTap: isEditable && (onStatusChanged != null || onPresentPressed != null)
                          ? () {
                        onStatusChanged?.call(AttendanceStatus.present);
                        onPresentPressed?.call();
                      }
                          : null,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isMarkedPresent
                              ? AppColors.secondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: isMarkedPresent
                              ? const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.08),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            )
                          ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: 15,
                              color: isMarkedPresent
                                  ? AppColors.onSecondary
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Presente',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isMarkedPresent
                                    ? AppColors.onSecondary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 2),

                    // Botón Falta
                    InkWell(
                      onTap: isEditable && (onStatusChanged != null || onAbsentPressed != null)
                          ? () {
                        onStatusChanged?.call(AttendanceStatus.absent);
                        onAbsentPressed?.call();
                      }
                          : null,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isMarkedAbsent
                              ? AppColors.error
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: isMarkedAbsent
                              ? const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.08),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            )
                          ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close,
                              size: 15,
                              color: isMarkedAbsent
                                  ? AppColors.onError
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Falta',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isMarkedAbsent
                                    ? AppColors.onError
                                    : AppColors.onSurfaceVariant,
                              ),
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
        ],
      ),
    );
  }

  void _openNoteDialog(BuildContext context, String studentName) {
    final textController = TextEditingController(
      text: note ?? medicalNote ?? student?.medicalNote ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nota / Justificante', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Motivo de falta / observación',
                hintText: 'Ej. Cita médica, permiso familiar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          if (onNoteChanged != null)
            FilledButton(
              onPressed: () {
                onNoteChanged!(textController.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials(String initials, String name) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isNotEmpty
            ? initials
            : (name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'AL'),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

