import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/students_provider.dart';

class AddStudentModal extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const AddStudentModal({
    super.key,
    this.courseId = 'course-1',
    this.courseName = 'Inglés Avanzado B2',
  });

  @override
  ConsumerState<AddStudentModal> createState() => _AddStudentModalState();
}

class _AddStudentModalState extends ConsumerState<AddStudentModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController(text: '16');
  final _tutorNameController = TextEditingController();
  final _tutorPhoneController = TextEditingController();
  final _tutorEmailController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _tutorNameController.dispose();
    _tutorPhoneController.dispose();
    _tutorEmailController.dispose();
    _secondaryPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(studentsForCourseProvider(widget.courseId).notifier)
          .addStudent(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 16,
        tutorName: _tutorNameController.text.trim().isNotEmpty
            ? _tutorNameController.text.trim()
            : l10n.tutorFallback,
        tutorPhone: _tutorPhoneController.text.trim(),
        tutorEmail: _tutorEmailController.text.trim().isNotEmpty
            ? _tutorEmailController.text.trim()
            : l10n.emailHint,
        secondaryPhone: _secondaryPhoneController.text.trim(),
      );

      ref.read(studentsRevisionProvider.notifier).state++;
      ref.invalidate(allActiveStudentsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
                const SizedBox(width: 8),
                Text(l10n.studentRegisteredSuccess),
              ],
            ),
            backgroundColor: AppColors.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariantAdaptive(context),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_add, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.addStudentTitle,
                        style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              Text(
                l10n.addStudentDesc(widget.courseName),
                style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: l10n.firstNamesLabel,
                      controller: _nameController,
                      hint: l10n.firstNameHint,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.required : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      label: l10n.lastNamesLabel,
                      controller: _lastNameController,
                      hint: l10n.lastNameHint,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.required : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: l10n.ageLabel,
                controller: _ageController,
                hint: '16',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: l10n.tutorNameLabel,
                controller: _tutorNameController,
                hint: l10n.tutorNameHint,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: l10n.tutorPhoneRequiredLabel,
                controller: _tutorPhoneController,
                hint: '+54 9 11 4522 8901',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.call, color: AppColors.secondary, size: 20),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.phoneRequiredWhatsapp : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: l10n.emailLabel,
                controller: _tutorEmailController,
                hint: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: textPrimary,
                      backgroundColor: AppColors.surfaceMid(context),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: AppColors.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.check, size: 18),
                    label: Text(l10n.register, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: textSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.outlineAdaptive(context),
            ),
            filled: true,
            fillColor: AppColors.surfaceLow(context),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
