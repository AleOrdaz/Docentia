import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'certificate_preview_screen.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../models/certificate_model.dart';
import '../services/certificate_pdf_service.dart';
import '../services/certificate_service.dart';
import '../widgets/certificate_diploma.dart';

class IssueCertificatesScreen extends ConsumerStatefulWidget {
  final String courseId;

  const IssueCertificatesScreen({super.key, required this.courseId});

  @override
  ConsumerState<IssueCertificatesScreen> createState() =>
      _IssueCertificatesScreenState();
}

class _IssueCertificatesScreenState
    extends ConsumerState<IssueCertificatesScreen> {
  CertificateStyle _style = CertificateStyle.classic;
  CertificateType _type = CertificateType.completion;
  final Set<String> _selectedIds = {};
  bool _generating = false;
  bool _didInitSelection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedCourseIdProvider.notifier).state = widget.courseId;
    });
  }

  void _ensureSelection(List<Student> students) {
    final valid = students.map((student) => student.id).toSet();
    _selectedIds.removeWhere((id) => !valid.contains(id));
    if (!_didInitSelection && students.isNotEmpty) {
      _didInitSelection = true;
      _selectedIds.addAll(valid);
    }
  }

  Future<void> _generate(
    AppLocalizations l10n,
    List<Student> students,
    String courseName,
  ) async {
    final selected = students
        .where((student) => _selectedIds.contains(student.id))
        .toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.certificatePickStudents)),
      );
      return;
    }

    final teacher = ref.read(authProvider).teacher?.name.trim();
    final copy = _copyFor(l10n, DateTime.now());
    final primary = Theme.of(context).colorScheme.primary;
    final accent = PdfColor(primary.r, primary.g, primary.b);

    setState(() => _generating = true);
    try {
      final issued = await CertificateService().issueCertificates(
        students: selected,
        courseId: widget.courseId,
        courseName: courseName,
        type: _type,
        style: _style,
      );
      final bytes = await CertificatePdfService().build(
        certificates: issued,
        copy: copy,
        teacherName: (teacher == null || teacher.isEmpty) ? 'Docentia' : teacher,
        accent: accent,
      );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CertificatePreviewScreen(
            bytes: bytes,
            filename: 'Docentia-${issued.first.folio}.pdf',
            certificates: issued,
            copy: copy,
            teacherName:
                (teacher == null || teacher.isEmpty) ? 'Docentia' : teacher,
            accent: primary,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetail('$error'))),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  CertificateCopy _copyFor(AppLocalizations l10n, DateTime issuedAt) {
    final title = switch (_type) {
      CertificateType.completion => l10n.certificateTitleCompletion,
      CertificateType.approval => l10n.certificateTitleApproval,
      CertificateType.participation => l10n.certificateTitleParticipation,
    };
    final body = switch (_type) {
      CertificateType.completion => l10n.certificateCompletionBody,
      CertificateType.approval => l10n.certificateApprovalBody,
      CertificateType.participation => l10n.certificateParticipationBody,
    };
    final locale = Localizations.localeOf(context).toString();
    return CertificateCopy(
      brand: l10n.appName,
      title: title,
      confers: l10n.certificateConfers,
      body: body,
      issuedOn: l10n.certificateIssuedIn(
        DateFormat.yMMMMd(locale).format(issuedAt),
      ),
      teacherLabel: l10n.certificateTeacherSign,
      folioLabel: l10n.certificateFolioLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final course = ref.watch(selectedCourseProvider);
    final studentsAsync = ref.watch(studentsForCourseProvider(widget.courseId));
    final courseName = course?.name ?? l10n.courseFallback;
    final primary = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return studentsAsync.when(
      loading: () => AppFormPage(
        title: l10n.certificatesTitle,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppFormPage(
        title: l10n.certificatesTitle,
        body: Text(l10n.errorWithDetail('$error')),
      ),
      data: (students) {
        _ensureSelection(students);
        final allSelected =
            students.isNotEmpty && _selectedIds.length == students.length;

        return AppFormPage(
          title: l10n.certificatesTitle,
          subtitle: l10n.certificatesSubtitle,
          footer: AppPrimaryButton(
            label: l10n.certificateGenerate,
            icon: Icons.picture_as_pdf_outlined,
            loading: _generating,
            onPressed: students.isEmpty
                ? null
                : () => _generate(l10n, students, courseName),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFieldLabel(l10n.certificateStyleLabel),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final style in CertificateStyle.values) ...[
                    if (style != CertificateStyle.classic) const SizedBox(width: 8),
                    Expanded(
                      child: _StyleCard(
                        style: style,
                        selected: _style == style,
                        title: switch (style) {
                          CertificateStyle.classic => l10n.certificateStyleClassic,
                          CertificateStyle.modern => l10n.certificateStyleModern,
                          CertificateStyle.elegant => l10n.certificateStyleElegant,
                        },
                        onTap: () => setState(() => _style = style),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              AppFieldLabel(l10n.certificateTypeLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in CertificateType.values)
                    ChoiceChip(
                      selected: _type == type,
                      selectedColor: primary,
                      labelStyle: TextStyle(
                        color: _type == type
                            ? AppColors.onPrimary
                            : textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      label: Text(switch (type) {
                        CertificateType.completion =>
                          l10n.certificateTypeCompletion,
                        CertificateType.approval => l10n.certificateTypeApproval,
                        CertificateType.participation =>
                          l10n.certificateTypeParticipation,
                      }),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: AppFieldLabel(l10n.certificateStudentsLabel),
                  ),
                  if (students.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (allSelected) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds
                              ..clear()
                              ..addAll(students.map((student) => student.id));
                          }
                        });
                      },
                      child: Text(
                        allSelected
                            ? l10n.certificateClearSelection
                            : l10n.certificateSelectAll,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (students.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l10n.certificateNoStudents,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                )
              else ...[
                Text(
                  l10n.certificateSelectedCount(_selectedIds.length),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                ...students.map((student) {
                  final selected = _selectedIds.contains(student.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isDark
                          ? const Color(0xFF151D2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: CheckboxListTile(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(student.id);
                            } else {
                              _selectedIds.remove(student.id);
                            }
                          });
                        },
                        activeColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: Text(
                          student.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StyleCard extends StatelessWidget {
  final CertificateStyle style;
  final bool selected;
  final String title;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.selected,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inner = switch (style) {
      CertificateStyle.classic => const Color(0xFF00236F),
      CertificateStyle.modern => primary,
      CertificateStyle.elegant => const Color(0xFF6B2D5B),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : AppColors.outlineVariantAdaptive(context),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CertificateStyleThumb(
                    style: style,
                    accent: inner,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
