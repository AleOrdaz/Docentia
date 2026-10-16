import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Dismissible(
      key: ValueKey('att_swipe_${student?.id ?? name}_${effectiveStatus?.name ?? "none"}'),
      direction: isEditable ? DismissDirection.horizontal : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD8F3DC),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00796B), size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.presentStatus,
              style: const TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.absentStatus,
              style: const TextStyle(
                color: Color(0xFFBA1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.cancel_rounded, color: Color(0xFFBA1A1A), size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (!isEditable) return false;
        if (direction == DismissDirection.startToEnd) {
          // Deslizar hacia la derecha: Marcar presente
          onStatusChanged?.call(AttendanceStatus.present);
          onPresentPressed?.call();
        } else if (direction == DismissDirection.endToStart) {
          // Deslizar hacia la izquierda: Marcar falta
          onStatusChanged?.call(AttendanceStatus.absent);
          onAbsentPressed?.call();
        }
        return false; // Conservar el elemento en pantalla con su estado actualizado
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
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
                              Text(l10n.yearsOld(displayAge), style: AppTextStyles.bodySmall),
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
                                l10n.unmarkedStatus,
                                style: AppTextStyles.bodySmall,
                              )
                            else
                              Text(
                                l10n.attendancePctShort(attendancePct ?? 90),
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

            // Fila inferior: Estado visual y acciones (sin botones individuales Presente/Falta)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (displayNote != null && displayNote.isNotEmpty)
                  InkWell(
                    onTap: isEditable ? () => _openNoteDialog(context, displayName) : null,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            isMarkedExcused ? l10n.excusedStatus : l10n.viewNote,
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
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_rounded,
                        size: 15,
                        color: isEditable
                            ? AppColors.onSurfaceVariant.withValues(alpha: 0.7)
                            : AppColors.outlineVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEditable
                            ? (effectiveStatus == null
                            ? l10n.swipeMarkHint
                            : l10n.swipeCorrectHint)
                            : l10n.classDaysOnly,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isEditable
                              ? AppColors.onSurfaceVariant.withValues(alpha: 0.8)
                              : AppColors.outlineVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                // Indicador visual de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isMarkedPresent
                        ? const Color(0xFFD8F3DC)
                        : isMarkedAbsent
                        ? const Color(0xFFFDE8E8)
                        : isMarkedExcused
                        ? const Color(0xFFEDE7F6)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isMarkedPresent
                          ? const Color(0xFFA7E9B8)
                          : isMarkedAbsent
                          ? const Color(0xFFFAC4C4)
                          : isMarkedExcused
                          ? const Color(0xFFD1C4E9)
                          : const Color(0xFFE2E6EF),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMarkedPresent) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: Color(0xFF00796B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.presentStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00796B),
                          ),
                        ),
                      ] else if (isMarkedAbsent) ...[
                        const Icon(
                          Icons.cancel_rounded,
                          size: 15,
                          color: Color(0xFFBA1A1A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.absentStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBA1A1A),
                          ),
                        ),
                      ] else if (isMarkedExcused) ...[
                        const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 15,
                          color: Color(0xFF6750A4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.excusedStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6750A4),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9EA3AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.notRecorded,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openNoteDialog(BuildContext context, String studentName) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController(
      text: note ?? medicalNote ?? student?.medicalNote ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.noteTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              decoration: InputDecoration(
                labelText: l10n.noteReasonLabel,
                hintText: l10n.noteHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
          if (onNoteChanged != null)
            FilledButton(
              onPressed: () {
                onNoteChanged!(textController.text.trim());
                Navigator.pop(ctx);
              },
              child: Text(l10n.save),
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

