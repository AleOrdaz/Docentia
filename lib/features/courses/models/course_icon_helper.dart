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
  // Educación general y Pedagogía
  CourseIconCategory(key: 'school', name: 'Escuela / Educación', icon: Icons.school_outlined),
  CourseIconCategory(key: 'books', name: 'Libros y Lectura', icon: Icons.menu_book_rounded),
  CourseIconCategory(key: 'reading', name: 'Literatura / Historias', icon: Icons.auto_stories_outlined),
  CourseIconCategory(key: 'lecture', name: 'Clase Magistral', icon: Icons.cast_for_education_rounded),
  CourseIconCategory(key: 'achievement', name: 'Certificación / Mérito', icon: Icons.workspace_premium_outlined),

  // Matemáticas
  CourseIconCategory(key: 'math', name: 'Matemáticas / Cálculo', icon: Icons.calculate_outlined),
  CourseIconCategory(key: 'functions', name: 'Álgebra y Funciones', icon: Icons.functions_rounded),
  CourseIconCategory(key: 'geometry', name: 'Geometría y Reglas', icon: Icons.square_foot_rounded),
  CourseIconCategory(key: 'statistics', name: 'Estadística y Porcentaje', icon: Icons.percent_rounded),
  CourseIconCategory(key: 'shapes', name: 'Formas y Figuras', icon: Icons.category_outlined),
  CourseIconCategory(key: 'analytics', name: 'Análisis y Gráficos', icon: Icons.timeline_rounded),

  // Programación, Robótica y Tecnología
  CourseIconCategory(key: 'programming', name: 'Programación / Terminal', icon: Icons.terminal_rounded),
  CourseIconCategory(key: 'code', name: 'Código y Desarrollo', icon: Icons.code_rounded),
  CourseIconCategory(key: 'robotics', name: 'Robótica e Inteligencia', icon: Icons.smart_toy_outlined),
  CourseIconCategory(key: 'computing', name: 'Computación y Sistemas', icon: Icons.computer_rounded),
  CourseIconCategory(key: 'data', name: 'Datos y Algoritmos', icon: Icons.data_object_rounded),
  CourseIconCategory(key: 'hardware', name: 'Hardware y Circuitos', icon: Icons.memory_rounded),
  CourseIconCategory(key: 'mobile', name: 'Dispositivos y Apps', icon: Icons.devices_rounded),

  // Ciencias Naturales y Experimentales
  CourseIconCategory(key: 'science', name: 'Ciencias y Laboratorio', icon: Icons.science_outlined),
  CourseIconCategory(key: 'physics', name: 'Física y Energía', icon: Icons.bolt_rounded),
  CourseIconCategory(key: 'chemistry', name: 'Química y Moléculas', icon: Icons.biotech_outlined),
  CourseIconCategory(key: 'biology', name: 'Biología y Ecología', icon: Icons.eco_outlined),
  CourseIconCategory(key: 'space', name: 'Astronomía y Aeroespacial', icon: Icons.rocket_launch_outlined),
  CourseIconCategory(key: 'health', name: 'Salud y Anatomía', icon: Icons.health_and_safety_outlined),

  // Idiomas y Comunicación
  CourseIconCategory(key: 'english', name: 'Inglés', icon: Icons.translate_rounded),
  CourseIconCategory(key: 'languages', name: 'Idiomas del Mundo', icon: Icons.language_rounded),
  CourseIconCategory(key: 'world', name: 'Mundo y Globalización', icon: Icons.public_rounded),
  CourseIconCategory(key: 'speech', name: 'Oratoria y Expresión', icon: Icons.record_voice_over_outlined),
  CourseIconCategory(key: 'grammar', name: 'Ortografía y Gramática', icon: Icons.spellcheck_rounded),
  CourseIconCategory(key: 'debate', name: 'Debate y Conversación', icon: Icons.forum_outlined),

  // Ciencias Sociales y Humanidades
  CourseIconCategory(key: 'history', name: 'Historia y Humanidades', icon: Icons.history_edu_rounded),
  CourseIconCategory(key: 'mind', name: 'Psicología y Filosofía', icon: Icons.psychology_outlined),

  // Arte, Diseño y Música
  CourseIconCategory(key: 'art', name: 'Artes Plásticas y Pintura', icon: Icons.palette_outlined),
  CourseIconCategory(key: 'drawing', name: 'Dibujo e Ilustración', icon: Icons.brush_outlined),
  CourseIconCategory(key: 'design', name: 'Diseño Gráfico', icon: Icons.design_services_outlined),
  CourseIconCategory(key: 'music', name: 'Música y Notas', icon: Icons.music_note_rounded),
  CourseIconCategory(key: 'piano', name: 'Instrumentos y Piano', icon: Icons.piano_outlined),
  CourseIconCategory(key: 'theater', name: 'Teatro y Expresión', icon: Icons.theater_comedy_outlined),
  CourseIconCategory(key: 'cinema', name: 'Cine y Audiovisual', icon: Icons.movie_outlined),
  CourseIconCategory(key: 'photo', name: 'Fotografía', icon: Icons.photo_camera_outlined),

  // Deportes, Negocios y Otras Materias
  CourseIconCategory(key: 'sports', name: 'Deportes y Fútbol', icon: Icons.sports_soccer_rounded),
  CourseIconCategory(key: 'fitness', name: 'Educación Física y Gym', icon: Icons.fitness_center_rounded),
  CourseIconCategory(key: 'basketball', name: 'Baloncesto', icon: Icons.sports_basketball_rounded),
  CourseIconCategory(key: 'economy', name: 'Economía y Finanzas', icon: Icons.account_balance_outlined),
  CourseIconCategory(key: 'business', name: 'Emprendimiento y Negocios', icon: Icons.lightbulb_outline),
  CourseIconCategory(key: 'architecture', name: 'Arquitectura y Dibujo Técnico', icon: Icons.architecture_rounded),
  CourseIconCategory(key: 'other', name: 'Otras Materias', icon: Icons.grade_outlined),
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
