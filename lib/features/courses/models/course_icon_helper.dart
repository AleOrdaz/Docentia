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

IconData getCourseIcon(String? iconKey) {
  if (iconKey == null || iconKey.isEmpty) return Icons.smart_toy_outlined;
  for (final cat in kCourseIconCategories) {
    if (cat.key.toLowerCase() == iconKey.toLowerCase()) {
      return cat.icon;
    }
  }
  return Icons.school_outlined;
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
