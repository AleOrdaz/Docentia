import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/courses/models/course_model.dart';
import '../../features/students/models/student_model.dart';
import '../../features/attendance/models/attendance_model.dart';
import '../../features/payments/models/payment_model.dart';
import '../../features/finance/models/expense_model.dart';
import '../../features/attendance/models/calendar_event_model.dart';
import '../../features/auth/models/teacher_model.dart';

class StorageService {
  static const String _keyCourses = 'docentia_courses';
  static const String _keyStudents = 'docentia_students';
  static const String _keyAttendance = 'docentia_attendance';
  static const String _keyAttendanceSessions = 'docentia_attendance_sessions';
  static const String _keyPayments = 'docentia_payments';
  static const String _keyExpenses = 'docentia_expenses';
  static const String _keyThemeColorIndex = 'docentia_theme_color_index';
  static const String _keyThemeMode = 'docentia_theme_mode';
  static const String _keyCalendarEvents = 'docentia_calendar_events';
  static const String _keyLanguage = 'docentia_language';
  static const String _keyTeacherPrefix = 'docentia_teacher_';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- Language (Default: Spanish 'es') ---
  static Future<String> getLanguageCode() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_keyLanguage) ?? 'es';
    } catch (_) {
      return 'es';
    }
  }

  static Future<void> saveLanguageCode(String code) async {
    try {
      final prefs = await _instance;
      await prefs.setString(_keyLanguage, code);
    } catch (_) {}
  }

  // --- Theme Color ---
  static Future<int> getThemeColorIndex() async {
    try {
      final prefs = await _instance;
      return prefs.getInt(_keyThemeColorIndex) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> saveThemeColorIndex(int index) async {
    try {
      final prefs = await _instance;
      await prefs.setInt(_keyThemeColorIndex, index);
    } catch (_) {}
  }

  // --- Courses ---
  static Future<List<Course>> getCourses() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyCourses);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Course.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCourses(List<Course> courses) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(courses.map((c) => c.toMap()).toList());
      await prefs.setString(_keyCourses, raw);
    } catch (_) {}
  }

  // --- Students ---
  static Future<List<Student>> getStudents() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyStudents);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Student.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveStudents(List<Student> students) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(students.map((s) => s.toMap()).toList());
      await prefs.setString(_keyStudents, raw);
    } catch (_) {}
  }

  // --- Attendance ---
  static Future<List<Attendance>> getAttendance() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyAttendance);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Attendance.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAttendance(List<Attendance> records) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(records.map((a) => a.toMap()).toList());
      await prefs.setString(_keyAttendance, raw);
    } catch (_) {}
  }

  // --- Attendance Sessions (Historial completo de clases) ---
  static Future<List<ClassAttendanceSession>> getAttendanceSessions() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyAttendanceSessions);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ClassAttendanceSession.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAttendanceSessions(List<ClassAttendanceSession> sessions) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(sessions.map((s) => s.toMap()).toList());
      await prefs.setString(_keyAttendanceSessions, raw);
    } catch (_) {}
  }

  // --- Payments ---
  static Future<List<Payment>> getPayments() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyPayments);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Payment.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePayments(List<Payment> payments) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(payments.map((p) => p.toMap()).toList());
      await prefs.setString(_keyPayments, raw);
    } catch (_) {}
  }

  // --- Expenses ---
  static Future<List<Expense>> getExpenses() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyExpenses);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Expense.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(expenses.map((e) => e.toMap()).toList());
      await prefs.setString(_keyExpenses, raw);
    } catch (_) {}
  }

  // --- Theme Mode ('light', 'dark', 'system') ---
  static Future<String> getThemeMode() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_keyThemeMode) ?? 'system';
    } catch (_) {
      return 'system';
    }
  }

  static Future<void> saveThemeMode(String mode) async {
    try {
      final prefs = await _instance;
      await prefs.setString(_keyThemeMode, mode);
    } catch (_) {}
  }

  // --- Calendar Events ---
  static Future<List<CalendarEvent>> getCalendarEvents() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_keyCalendarEvents);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => CalendarEvent.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCalendarEvents(List<CalendarEvent> events) async {
    try {
      final prefs = await _instance;
      final raw = jsonEncode(events.map((e) => e.toMap()).toList());
      await prefs.setString(_keyCalendarEvents, raw);
    } catch (_) {}
  }

  // --- Teacher profile ---
  static Future<Teacher?> getTeacher(String id) async {
    if (id.isEmpty) return null;
    try {
      final prefs = await _instance;
      final raw = prefs.getString('$_keyTeacherPrefix$id');
      if (raw == null || raw.isEmpty) return null;
      return Teacher.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveTeacher(Teacher teacher) async {
    if (teacher.id.isEmpty) return;
    try {
      final prefs = await _instance;
      await prefs.setString(
        '$_keyTeacherPrefix${teacher.id}',
        jsonEncode(teacher.toMap()),
      );
    } catch (_) {}
  }
}

