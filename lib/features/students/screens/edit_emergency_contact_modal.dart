import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/student_model.dart';
import '../providers/students_provider.dart';

class EditEmergencyContactModal extends ConsumerStatefulWidget {
  final Student student;

  const EditEmergencyContactModal({super.key, required this.student});

  @override
  ConsumerState<EditEmergencyContactModal> createState() =>
      _EditEmergencyContactModalState();
}

class _EditEmergencyContactModalState
    extends ConsumerState<EditEmergencyContactModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late TutorRelationship _relationship;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nameController = TextEditingController(text: student.emergencyName);
    _phoneController = TextEditingController(text: student.emergencyPhone);
    _relationship = student.emergencyRelationship;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final updated = widget.student.copyWith(
        emergencyName: _nameController.text.trim(),
        emergencyRelationship: _relationship,
        emergencyPhone: _phoneController.text.trim(),
      );

      await ref
          .read(studentsForCourseProvider(widget.student.courseId).notifier)
          .updateStudent(updated);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
              const SizedBox(width: 8),
              Text(l10n.emergencyUpdatedSuccess),
            ],
          ),
          backgroundColor: AppColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      );
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
                children: [
                  Icon(Icons.emergency_outlined, color: primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.editEmergencyTitle,
                      style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: l10n.nameLabel,
                controller: _nameController,
                hint: l10n.tutorNameHint,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.relationshipLabel,
                    style: AppTextStyles.labelMedium.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<TutorRelationship>(
                    initialValue: _relationship,
                    isExpanded: true,
                    style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceLow(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem(value: TutorRelationship.mother, child: Text(l10n.relationshipMother)),
                      DropdownMenuItem(value: TutorRelationship.father, child: Text(l10n.relationshipFather)),
                      DropdownMenuItem(value: TutorRelationship.tutor, child: Text(l10n.relationshipTutor)),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _relationship = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: l10n.mobilePhone,
                controller: _phoneController,
                hint: '+54 9 11 4522 8901',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.call, color: AppColors.secondary, size: 20),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.required : null,
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
                    label: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.w600)),
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
