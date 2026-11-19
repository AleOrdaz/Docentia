import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../utils/teacher_photo.dart';

class TeacherAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const TeacherAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.radius = 32,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = teacherImageProvider(photoUrl);
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: image,
      child: image == null
          ? ClipOval(
              child: ProfileAvatar(
                seed: (name?.trim().isNotEmpty ?? false)
                    ? name!.trim()
                    : 'docentia-teacher',
                size: radius * 2,
                semanticLabel: name,
              ),
            )
          : null,
    );

    Widget content = avatar;
    if (showEditBadge) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBg(context), width: 2),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: radius * 0.35,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: content,
    );
  }
}
