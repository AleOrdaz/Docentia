import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';

class EditTeacherProfileModal extends ConsumerStatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentBio;

  const EditTeacherProfileModal({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentBio,
  });

  @override
  ConsumerState<EditTeacherProfileModal> createState() =>
      _EditTeacherProfileModalState();
}

class _EditTeacherProfileModalState
    extends ConsumerState<EditTeacherProfileModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _phoneCtrl = TextEditingController(text: widget.currentPhone);
    _bioCtrl = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
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
        child: SafeArea(
          top: false,
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
                  Icon(Icons.edit_outlined, color: primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.editProfileData,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: textPrimary),
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
                label: l10n.profileTitle,
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: l10n.whatsappPhone,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon:
                const Icon(Icons.call, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: l10n.biography,
                controller: _bioCtrl,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: Text(l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: AppColors.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.check, size: 18),
                    label: Text(l10n.save,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
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
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? prefixIcon,
    int maxLines = 1,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(color: textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLow(context),
            prefixIcon: prefixIcon,
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