import 'package:flutter/material.dart';

class CourseIconCategory {
  final String key;
  final String name;
  final IconData icon;

  const CourseIconCategory({
    required this.key,
    required this.name,
    required this.icon,
  });
}

const List<CourseIconCategory> kCourseIconCategories = [
  CourseIconCategory(key: 'robotics', name: 'Robótica', icon: Icons.smart_toy_outlined),
  CourseIconCategory(key: 'math', name: 'Matemáticas', icon: Icons.calculate_outlined),
  CourseIconCategory(key: 'programming', name: 'Programación', icon: Icons.code_rounded),
  CourseIconCategory(key: 'computing', name: 'Computación', icon: Icons.computer_rounded),
  CourseIconCategory(key: 'electronics', name: 'Electrónica', icon: Icons.memory_outlined),
  CourseIconCategory(key: 'english', name: 'Inglés', icon: Icons.translate_rounded),
  CourseIconCategory(key: 'languages', name: 'Idiomas', icon: Icons.public_rounded),
  CourseIconCategory(key: 'speech', name: 'Oratoria', icon: Icons.record_voice_over_outlined),
  CourseIconCategory(key: 'science', name: 'Ciencias', icon: Icons.science_outlined),
  CourseIconCategory(key: 'physics', name: 'Física', icon: Icons.bolt_rounded),
  CourseIconCategory(key: 'chemistry', name: 'Química', icon: Icons.biotech_outlined),
  CourseIconCategory(key: 'biology', name: 'Biología', icon: Icons.eco_outlined),
  CourseIconCategory(key: 'astronomy', name: 'Astronomía', icon: Icons.star_border_rounded),
  CourseIconCategory(key: 'medicine', name: 'Medicina', icon: Icons.medical_services_outlined),
  CourseIconCategory(key: 'psychology', name: 'Psicología', icon: Icons.psychology_outlined),
  CourseIconCategory(key: 'music', name: 'Música', icon: Icons.music_note_rounded),
  CourseIconCategory(key: 'headphones', name: 'Audio', icon: Icons.headphones_outlined),
  CourseIconCategory(key: 'art', name: 'Arte', icon: Icons.palette_outlined),
  CourseIconCategory(key: 'design', name: 'Diseño', icon: Icons.brush_outlined),
  CourseIconCategory(key: 'photography', name: 'Fotografía', icon: Icons.photo_camera_outlined),
  CourseIconCategory(key: 'video', name: 'Video', icon: Icons.videocam_outlined),
  CourseIconCategory(key: 'theater', name: 'Teatro', icon: Icons.theater_comedy_outlined),
  CourseIconCategory(key: 'reading', name: 'Lectura', icon: Icons.auto_stories_outlined),
  CourseIconCategory(key: 'writing', name: 'Escritura', icon: Icons.edit_outlined),
  CourseIconCategory(key: 'history', name: 'Historia', icon: Icons.history_edu_rounded),
  CourseIconCategory(key: 'geography', name: 'Geografía', icon: Icons.map_outlined),
  CourseIconCategory(key: 'law', name: 'Derecho', icon: Icons.gavel_outlined),
  CourseIconCategory(key: 'business', name: 'Negocios', icon: Icons.business_center_outlined),
  CourseIconCategory(key: 'finance', name: 'Finanzas', icon: Icons.savings_outlined),
  CourseIconCategory(key: 'cooking', name: 'Cocina', icon: Icons.restaurant_outlined),
  CourseIconCategory(key: 'sports', name: 'Deportes', icon: Icons.sports_soccer_rounded),
  CourseIconCategory(key: 'basketball', name: 'Básquetbol', icon: Icons.sports_basketball_outlined),
  CourseIconCategory(key: 'swimming', name: 'Natación', icon: Icons.pool_outlined),
  CourseIconCategory(key: 'wellness', name: 'Bienestar', icon: Icons.self_improvement_outlined),
  CourseIconCategory(key: 'chess', name: 'Lógica', icon: Icons.extension_outlined),
  CourseIconCategory(key: 'gaming', name: 'Videojuegos', icon: Icons.sports_esports_outlined),
  CourseIconCategory(key: 'earlyChildhood', name: 'Infantil', icon: Icons.child_care_outlined),
  CourseIconCategory(key: 'other', name: 'Otros', icon: Icons.school_outlined),
];

class CourseIconColors {
  final Color lightIcon;
  final Color lightBackground;
  final Color darkIcon;
  final Color darkBackground;

  const CourseIconColors({
    required this.lightIcon,
    required this.lightBackground,
    required this.darkIcon,
    required this.darkBackground,
  });

  Color icon(bool isDark) => isDark ? darkIcon : lightIcon;
  Color background(bool isDark) => isDark ? darkBackground : lightBackground;
}

const _kDefaultCourseIconColors = CourseIconColors(
  lightIcon: Color(0xFF2563EB),
  lightBackground: Color(0xFFE8EEFF),
  darkIcon: Color(0xFF93C5FD),
  darkBackground: Color(0xFF1E2E4E),
);

const Map<String, CourseIconColors> kCourseIconColors = {
  'robotics': CourseIconColors(
    lightIcon: Color(0xFF2563EB),
    lightBackground: Color(0xFFE8EEFF),
    darkIcon: Color(0xFF93C5FD),
    darkBackground: Color(0xFF1E2E4E),
  ),
  'math': CourseIconColors(
    lightIcon: Color(0xFF4F46E5),
    lightBackground: Color(0xFFE0E7FF),
    darkIcon: Color(0xFFA5B4FC),
    darkBackground: Color(0xFF1E1B4B),
  ),
  'programming': CourseIconColors(
    lightIcon: Color(0xFF0284C7),
    lightBackground: Color(0xFFE0F2FE),
    darkIcon: Color(0xFF7DD3FC),
    darkBackground: Color(0xFF0C2A3E),
  ),
  'computing': CourseIconColors(
    lightIcon: Color(0xFF0369A1),
    lightBackground: Color(0xFFE0F2FE),
    darkIcon: Color(0xFF7DD3FC),
    darkBackground: Color(0xFF0B2A3D),
  ),
  'electronics': CourseIconColors(
    lightIcon: Color(0xFF0F766E),
    lightBackground: Color(0xFFCCFBF1),
    darkIcon: Color(0xFF5EEAD4),
    darkBackground: Color(0xFF13403A),
  ),
  'english': CourseIconColors(
    lightIcon: Color(0xFF0D9488),
    lightBackground: Color(0xFFCCFBF1),
    darkIcon: Color(0xFF5EEAD4),
    darkBackground: Color(0xFF13403A),
  ),
  'languages': CourseIconColors(
    lightIcon: Color(0xFF0891B2),
    lightBackground: Color(0xFFCFFAFE),
    darkIcon: Color(0xFF67E8F9),
    darkBackground: Color(0xFF164E63),
  ),
  'speech': CourseIconColors(
    lightIcon: Color(0xFFDB2777),
    lightBackground: Color(0xFFFCE7F3),
    darkIcon: Color(0xFFF9A8D4),
    darkBackground: Color(0xFF4A1D36),
  ),
  'science': CourseIconColors(
    lightIcon: Color(0xFF059669),
    lightBackground: Color(0xFFD1FAE5),
    darkIcon: Color(0xFF6EE7B7),
    darkBackground: Color(0xFF064E3B),
  ),
  'physics': CourseIconColors(
    lightIcon: Color(0xFFF59E0B),
    lightBackground: Color(0xFFFEF3C7),
    darkIcon: Color(0xFFFCD34D),
    darkBackground: Color(0xFF3F2E0A),
  ),
  'chemistry': CourseIconColors(
    lightIcon: Color(0xFFCA8A04),
    lightBackground: Color(0xFFFEF9C3),
    darkIcon: Color(0xFFFDE047),
    darkBackground: Color(0xFF3F3A0A),
  ),
  'biology': CourseIconColors(
    lightIcon: Color(0xFF16A34A),
    lightBackground: Color(0xFFDCFCE7),
    darkIcon: Color(0xFF86EFAC),
    darkBackground: Color(0xFF14532D),
  ),
  'astronomy': CourseIconColors(
    lightIcon: Color(0xFF7C3AED),
    lightBackground: Color(0xFFF3E8FF),
    darkIcon: Color(0xFFC4B5FD),
    darkBackground: Color(0xFF2E1B4E),
  ),
  'medicine': CourseIconColors(
    lightIcon: Color(0xFFDC2626),
    lightBackground: Color(0xFFFEE2E2),
    darkIcon: Color(0xFFFCA5A5),
    darkBackground: Color(0xFF3F1D1D),
  ),
  'psychology': CourseIconColors(
    lightIcon: Color(0xFF9333EA),
    lightBackground: Color(0xFFF3E8FF),
    darkIcon: Color(0xFFD8B4FE),
    darkBackground: Color(0xFF3B1D5A),
  ),
  'music': CourseIconColors(
    lightIcon: Color(0xFFE11D48),
    lightBackground: Color(0xFFFFE4E6),
    darkIcon: Color(0xFFFDA4AF),
    darkBackground: Color(0xFF4C1D24),
  ),
  'headphones': CourseIconColors(
    lightIcon: Color(0xFFBE185D),
    lightBackground: Color(0xFFFCE7F3),
    darkIcon: Color(0xFFF9A8D4),
    darkBackground: Color(0xFF4A1D36),
  ),
  'art': CourseIconColors(
    lightIcon: Color(0xFF7C3AED),
    lightBackground: Color(0xFFF3E8FF),
    darkIcon: Color(0xFFC4B5FD),
    darkBackground: Color(0xFF2E1B4E),
  ),
  'design': CourseIconColors(
    lightIcon: Color(0xFFC026D3),
    lightBackground: Color(0xFFFAE8FF),
    darkIcon: Color(0xFFF0ABFC),
    darkBackground: Color(0xFF4A1D4E),
  ),
  'photography': CourseIconColors(
    lightIcon: Color(0xFFEA580C),
    lightBackground: Color(0xFFFFEDD5),
    darkIcon: Color(0xFFFB923C),
    darkBackground: Color(0xFF431407),
  ),
  'video': CourseIconColors(
    lightIcon: Color(0xFFDC2626),
    lightBackground: Color(0xFFFEE2E2),
    darkIcon: Color(0xFFFCA5A5),
    darkBackground: Color(0xFF3F1D1D),
  ),
  'theater': CourseIconColors(
    lightIcon: Color(0xFFDB2777),
    lightBackground: Color(0xFFFCE7F3),
    darkIcon: Color(0xFFF9A8D4),
    darkBackground: Color(0xFF4A1D36),
  ),
  'reading': CourseIconColors(
    lightIcon: Color(0xFFB45309),
    lightBackground: Color(0xFFFEF3C7),
    darkIcon: Color(0xFFFCD34D),
    darkBackground: Color(0xFF3F2E0A),
  ),
  'writing': CourseIconColors(
    lightIcon: Color(0xFF1D4ED8),
    lightBackground: Color(0xFFDBEAFE),
    darkIcon: Color(0xFF93C5FD),
    darkBackground: Color(0xFF1E3A5F),
  ),
  'history': CourseIconColors(
    lightIcon: Color(0xFF92400E),
    lightBackground: Color(0xFFFDE68A),
    darkIcon: Color(0xFFFBBF24),
    darkBackground: Color(0xFF3F2E0A),
  ),
  'geography': CourseIconColors(
    lightIcon: Color(0xFF15803D),
    lightBackground: Color(0xFFDCFCE7),
    darkIcon: Color(0xFF86EFAC),
    darkBackground: Color(0xFF14532D),
  ),
  'law': CourseIconColors(
    lightIcon: Color(0xFF334155),
    lightBackground: Color(0xFFE2E8F0),
    darkIcon: Color(0xFFCBD5E1),
    darkBackground: Color(0xFF1E293B),
  ),
  'business': CourseIconColors(
    lightIcon: Color(0xFF1E40AF),
    lightBackground: Color(0xFFDBEAFE),
    darkIcon: Color(0xFF93C5FD),
    darkBackground: Color(0xFF1E3A5F),
  ),
  'finance': CourseIconColors(
    lightIcon: Color(0xFF047857),
    lightBackground: Color(0xFFD1FAE5),
    darkIcon: Color(0xFF6EE7B7),
    darkBackground: Color(0xFF064E3B),
  ),
  'cooking': CourseIconColors(
    lightIcon: Color(0xFFC2410C),
    lightBackground: Color(0xFFFFEDD5),
    darkIcon: Color(0xFFFB923C),
    darkBackground: Color(0xFF431407),
  ),
  'sports': CourseIconColors(
    lightIcon: Color(0xFF16A34A),
    lightBackground: Color(0xFFDCFCE7),
    darkIcon: Color(0xFF86EFAC),
    darkBackground: Color(0xFF14532D),
  ),
  'basketball': CourseIconColors(
    lightIcon: Color(0xFFEA580C),
    lightBackground: Color(0xFFFFEDD5),
    darkIcon: Color(0xFFFB923C),
    darkBackground: Color(0xFF431407),
  ),
  'swimming': CourseIconColors(
    lightIcon: Color(0xFF0284C7),
    lightBackground: Color(0xFFE0F2FE),
    darkIcon: Color(0xFF7DD3FC),
    darkBackground: Color(0xFF0C2A3E),
  ),
  'wellness': CourseIconColors(
    lightIcon: Color(0xFF0D9488),
    lightBackground: Color(0xFFCCFBF1),
    darkIcon: Color(0xFF5EEAD4),
    darkBackground: Color(0xFF13403A),
  ),
  'chess': CourseIconColors(
    lightIcon: Color(0xFF475569),
    lightBackground: Color(0xFFE2E8F0),
    darkIcon: Color(0xFFCBD5E1),
    darkBackground: Color(0xFF1E293B),
  ),
  'gaming': CourseIconColors(
    lightIcon: Color(0xFF7C3AED),
    lightBackground: Color(0xFFF3E8FF),
    darkIcon: Color(0xFFC4B5FD),
    darkBackground: Color(0xFF2E1B4E),
  ),
  'earlyChildhood': CourseIconColors(
    lightIcon: Color(0xFFDB2777),
    lightBackground: Color(0xFFFCE7F3),
    darkIcon: Color(0xFFF9A8D4),
    darkBackground: Color(0xFF4A1D36),
  ),
  'other': _kDefaultCourseIconColors,
};

IconData getCourseIcon(String? iconKey) {
  if (iconKey == null || iconKey.isEmpty) return Icons.smart_toy_outlined;
  for (final cat in kCourseIconCategories) {
    if (cat.key.toLowerCase() == iconKey.toLowerCase()) {
      return cat.icon;
    }
  }
  return Icons.school_outlined;
}

CourseIconColors getCourseIconColors(String? iconKey) {
  if (iconKey == null || iconKey.isEmpty) return kCourseIconColors['robotics']!;
  return kCourseIconColors[iconKey] ?? _kDefaultCourseIconColors;
}

String getCourseIconName(String? iconKey) {
  if (iconKey == null || iconKey.isEmpty) return 'Robótica';
  for (final cat in kCourseIconCategories) {
    if (cat.key.toLowerCase() == iconKey.toLowerCase()) {
      return cat.name;
    }
  }
  return 'Curso';
}
