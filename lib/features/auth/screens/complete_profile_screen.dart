import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../utils/teacher_name.dart';
import '../utils/teacher_photo.dart';
import '../widgets/teacher_avatar.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final teacher = ref.read(authProvider).teacher;
    final name = teacher?.name.trim() ?? '';
    if (name.isNotEmpty && name != kFallbackTeacherName) {
      _nameCtrl.text = name;
    }
    _phoneCtrl.text = teacher?.phone ?? '';
    _bioCtrl.text = teacher?.bio ?? '';
    _photoPath = teacher?.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.completeProfileGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.completeProfileCamera),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;

    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final teacherId = ref.read(authProvider).teacher?.id ?? 'teacher';
    final savedPath = await persistTeacherPhoto(
      sourcePath: file.path,
      teacherId: teacherId,
    );
    if (!mounted) return;
    setState(() => _photoPath = savedPath);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            photoUrl: _photoPath,
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teacher = ref.watch(authProvider).teacher;
    final email = teacher?.email ?? '';

    return AppFormPage(
      title: l10n.completeProfileTitle,
      subtitle: l10n.completeProfileSubtitle,
      footer: Column(
        children: [
          AppPrimaryButton(
            label: l10n.completeProfileContinue,
            loading: _saving,
            onPressed: _submit,
          ),
          TextButton(
            onPressed: _saving
                ? null
                : () => ref.read(authProvider.notifier).signOut(),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TeacherAvatar(
              photoUrl: _photoPath,
              name: _nameCtrl.text,
              radius: 52,
              showEditBadge: true,
              onTap: _pickPhoto,
            ),
            TextButton(
              onPressed: _pickPhoto,
              child: Text(l10n.completeProfilePhotoHint),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: l10n.completeProfileNameLabel,
              controller: _nameCtrl,
              hint: l10n.completeProfileNameHint,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return l10n.completeProfileNameRequired;
                if (!isPersonName(name, email: email)) {
                  return l10n.completeProfileNameInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: l10n.completeProfilePhoneLabel,
              controller: _phoneCtrl,
              hint: l10n.completeProfilePhoneHint,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.call, size: 20),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: l10n.completeProfileBioLabel,
              controller: _bioCtrl,
              hint: l10n.completeProfileBioHint,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
