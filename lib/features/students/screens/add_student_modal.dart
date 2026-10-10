import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
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

    try {
      await ref
          .read(studentsForCourseProvider(widget.courseId).notifier)
          .addStudent(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 16,
        tutorName: _tutorNameController.text.trim().isNotEmpty
            ? _tutorNameController.text.trim()
            : 'Tutor',
        tutorPhone: _tutorPhoneController.text.trim(),
        tutorEmail: _tutorEmailController.text.trim().isNotEmpty
            ? _tutorEmailController.text.trim()
            : 'tutor@ejemplo.com',
        secondaryPhone: _secondaryPhoneController.text.trim(),
      );

      ref.read(studentsRevisionProvider.notifier).state++;
      ref.invalidate(allActiveStudentsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
                SizedBox(width: 8),
                Text('Alumno registrado con éxito'),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Título y botón cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_add, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('Agregar Alumno', style: AppTextStyles.titleLarge),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              Text(
                'Ingresa los datos para matricular e inscribir en ${widget.courseName}.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),

              // Nombres y Apellidos
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Nombres *',
                      controller: _nameController,
                      hint: 'Ej. Camila',
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      label: 'Apellidos *',
                      controller: _lastNameController,
                      hint: 'Ej. Morales Díaz',
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Edad
              _buildTextField(
                label: 'Edad',
                controller: _ageController,
                hint: '16',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Nombre del Tutor
              _buildTextField(
                label: 'Nombre del Tutor / Apoderado',
                controller: _tutorNameController,
                hint: 'Ej. Patricia Díaz',
              ),
              const SizedBox(height: 12),

              // Teléfono WhatsApp
              _buildTextField(
                label: 'Teléfono Móvil (WhatsApp) *',
                controller: _tutorPhoneController,
                hint: '+54 9 11 4522 8901',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.call, color: AppColors.secondary, size: 20),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Teléfono requerido para WhatsApp' : null,
              ),
              const SizedBox(height: 12),

              // Correo Electrónico
              _buildTextField(
                label: 'Correo Electrónico',
                controller: _tutorEmailController,
                hint: 'tutor@ejemplo.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      backgroundColor: AppColors.surfaceContainer,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                    label: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.w600)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
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
