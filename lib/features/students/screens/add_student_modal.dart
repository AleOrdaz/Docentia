import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/contact_picker_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/student_model.dart';
import '../providers/students_provider.dart';

class AddStudentModal extends ConsumerStatefulWidget {
  final String courseId;

  const AddStudentModal({
    super.key,
    this.courseId = 'course-1',
  });

  @override
  ConsumerState<AddStudentModal> createState() => _AddStudentModalState();
}

class _AddStudentModalState extends ConsumerState<AddStudentModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _tutorNameController = TextEditingController();
  final _tutorPhoneController = TextEditingController();
  final _tutorEmailController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  TutorRelationship _relationship = TutorRelationship.mother;
  TutorRelationship _emergencyRelationship = TutorRelationship.mother;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshFormState);
    _lastNameController.addListener(_refreshFormState);
    _tutorPhoneController.addListener(_refreshFormState);
  }

  void _refreshFormState() {
    if (mounted) setState(() {});
  }

  bool get _isFormReady {
    return _nameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _tutorPhoneController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _tutorNameController.dispose();
    _tutorPhoneController.dispose();
    _tutorEmailController.dispose();
    _secondaryPhoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
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
            age: 0,
            tutorRelationship: _relationship,
            tutorName: _tutorNameController.text.trim().isNotEmpty
                ? _tutorNameController.text.trim()
                : l10n.tutorFallback,
            tutorPhone: _tutorPhoneController.text.trim(),
            tutorEmail: _tutorEmailController.text.trim().isNotEmpty
                ? _tutorEmailController.text.trim()
                : l10n.emailHint,
            secondaryPhone: _secondaryPhoneController.text.trim(),
            emergencyName: _emergencyNameController.text.trim(),
            emergencyRelationship: _emergencyRelationship,
            emergencyPhone: _emergencyPhoneController.text.trim(),
          );

      ref.read(studentsRevisionProvider.notifier).state++;
      ref.invalidate(allActiveStudentsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.iconSuccess, size: 20),
                const SizedBox(width: 8),
                Text(l10n.studentRegisteredSuccess),
              ],
            ),
            backgroundColor: AppColors.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
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
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

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
                              color: AppColors.cardBorder(context),
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
                                  l10n.addStudentTitle,
                                  style: AppTextStyles.titleLarge
                                      .copyWith(color: textPrimary),
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
                        const SizedBox(height: 24),
                        _sectionTitle('Datos personales', Icons.badge_outlined,
                            textPrimary),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _buildTextField(
                              label: l10n.firstNamesLabel,
                              controller: _nameController,
                              hint: isEnglish
                                  ? 'e.g. Ana Sofía'
                                  : 'Ej. Ana Sofía',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.required
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: l10n.lastNamesLabel,
                              controller: _lastNameController,
                              hint: isEnglish
                                  ? 'e.g. García López'
                                  : 'Ej. García López',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.required
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _sectionTitle('Datos del tutor', Icons.people_outline,
                            textPrimary),
                        const SizedBox(height: 16),
                        _buildRelationshipField(
                          l10n,
                          value: _relationship,
                          onChanged: (value) =>
                              setState(() => _relationship = value),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: l10n.tutorNameLabel,
                          controller: _tutorNameController,
                          hint: isEnglish
                              ? 'e.g. María García'
                              : 'Ej. María García',
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: l10n.tutorPhoneRequiredLabel,
                          controller: _tutorPhoneController,
                          hint: '+52 55 1234 5678',
                          keyboardType: TextInputType.phone,
                          allowContactPicker: true,
                          prefixIcon: const Icon(Icons.call_outlined,
                              color: AppColors.iconDefault, size: 20),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.phoneRequiredWhatsapp
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: l10n.emailLabel,
                          controller: _tutorEmailController,
                          hint: isEnglish
                              ? 'e.g. maria@example.com'
                              : 'Ej. maria@correo.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 32),
                        _sectionTitle(l10n.emergencyContactTitle,
                            Icons.contact_emergency_outlined, textPrimary),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: l10n.nameLabel,
                                controller: _emergencyNameController,
                                hint: isEnglish
                                    ? 'e.g. Luis Hernández'
                                    : 'Ej. Luis Hernández',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildRelationshipField(
                                l10n,
                                value: _emergencyRelationship,
                                onChanged: (value) => setState(
                                    () => _emergencyRelationship = value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: l10n.mobilePhone,
                          controller: _emergencyPhoneController,
                          hint: '+52 55 1234 5678',
                          keyboardType: TextInputType.phone,
                          allowContactPicker: true,
                          prefixIcon: const Icon(Icons.call_outlined,
                              color: AppColors.iconDefault, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStickyFooter(
                  context: context,
                  primaryColor: primaryColor,
                  titleColor: textPrimary,
                  cancelLabel: l10n.cancel,
                  actionLabel: l10n.register,
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
    required Color primaryColor,
    required Color titleColor,
    required String cancelLabel,
    required String actionLabel,
  }) {
    final enabled = _isFormReady && !_isSubmitting;
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
            child: ElevatedButton.icon(
              onPressed: enabled ? _submit : null,
              icon: _isSubmitting
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
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(cancelLabel),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color foreground) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.iconDefault),
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

  Widget _buildRelationshipField(
    AppLocalizations l10n, {
    required TutorRelationship value,
    required ValueChanged<TutorRelationship> onChanged,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563);
    final inputColor =
        isDark ? const Color(0xFF30343B) : const Color(0xFFF1F3F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.relationshipLabel,
          style: AppTextStyles.labelMedium.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<TutorRelationship>(
          key: ValueKey('relationship-$value-${onChanged.hashCode}'),
          initialValue: value,
          isExpanded: true,
          style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: [
            DropdownMenuItem(
              value: TutorRelationship.mother,
              child: Text(l10n.relationshipMother),
            ),
            DropdownMenuItem(
              value: TutorRelationship.father,
              child: Text(l10n.relationshipFather),
            ),
            DropdownMenuItem(
              value: TutorRelationship.tutor,
              child: Text(l10n.relationshipTutor),
            ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }

  Future<void> _pickPhoneInto(TextEditingController controller) async {
    final phone = await ContactPickerService.pickPhoneNumber();
    if (!mounted || phone == null) return;
    setState(() => controller.text = phone);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    bool allowContactPicker = false,
    String? Function(String?)? validator,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563);
    final inputColor =
        isDark ? const Color(0xFF30343B) : const Color(0xFFF1F3F5);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: AppTextStyles.labelMedium.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: validator == null
                    ? label
                    : label.replaceFirst(RegExp(r'\s*\*$'), ''),
              ),
              if (validator != null)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
            ],
          ),
        ),
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
            fillColor: inputColor,
            prefixIcon: prefixIcon,
            suffixIcon: allowContactPicker
                ? IconButton(
                    tooltip: l10n.pickFromContacts,
                    onPressed: () => _pickPhoneInto(controller),
                    icon: const Icon(Icons.contacts_outlined,
                        color: AppColors.iconDefault, size: 22),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
