import '../models/teacher_model.dart';

const kFallbackTeacherName = 'Docente';

/// Elige el nombre visible del docente a partir de los datos de Google/Apple.
/// Nunca usa el correo (ni la parte local del correo) como nombre.
String resolveTeacherName({
  String? displayName,
  String? providerDisplayName,
  String? previousName,
  String email = '',
  String fallback = kFallbackTeacherName,
}) {
  for (final candidate in [displayName, providerDisplayName, previousName]) {
    if (isPersonName(candidate, email: email)) {
      return candidate!.trim();
    }
  }
  return fallback;
}

/// True si [value] es un nombre de persona usable, no un correo.
bool isPersonName(String? value, {String email = ''}) {
  if (value == null) return false;
  final name = value.trim();
  if (name.isEmpty) return false;
  if (looksLikeEmail(name)) return false;

  final normalizedEmail = email.trim().toLowerCase();
  if (normalizedEmail.isNotEmpty && name.toLowerCase() == normalizedEmail) {
    return false;
  }
  return true;
}

bool looksLikeEmail(String value) {
  final trimmed = value.trim();
  final at = trimmed.indexOf('@');
  if (at <= 0 || at == trimmed.length - 1) return false;
  return trimmed.substring(at + 1).contains('.');
}

/// True si el docente acaba de registrarse sin un nombre real
/// y hay que pedirle que personalice su cuenta.
bool teacherNeedsProfileSetup(Teacher? teacher) {
  if (teacher == null) return true;
  final name = teacher.name.trim();
  if (name == kFallbackTeacherName) return true;
  return !isPersonName(name, email: teacher.email);
}
