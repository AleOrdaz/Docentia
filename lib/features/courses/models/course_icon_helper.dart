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
  CourseIconCategory(key: 'english', name: 'Inglés', icon: Icons.translate_rounded),
  CourseIconCategory(key: 'science', name: 'Ciencias', icon: Icons.science_outlined),
  CourseIconCategory(key: 'physics', name: 'Física', icon: Icons.bolt_rounded),
  CourseIconCategory(key: 'chemistry', name: 'Química', icon: Icons.biotech_outlined),
  CourseIconCategory(key: 'music', name: 'Música', icon: Icons.music_note_rounded),
  CourseIconCategory(key: 'art', name: 'Arte', icon: Icons.palette_outlined),
  CourseIconCategory(key: 'sports', name: 'Deportes', icon: Icons.sports_soccer_rounded),
  CourseIconCategory(key: 'reading', name: 'Lectura', icon: Icons.auto_stories_outlined),
  CourseIconCategory(key: 'history', name: 'Historia', icon: Icons.history_edu_rounded),
  CourseIconCategory(key: 'languages', name: 'Idiomas', icon: Icons.public_rounded),
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
