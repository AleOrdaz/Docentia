enum AttendanceStatus {
  present,
  absent,
  excused,
}

class Attendance {
  final String id;
  final String studentId;
  final String courseId;
  final String date; // Formato YYYY-MM-DD
  final AttendanceStatus status;
  final String? note;

  const Attendance({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.status,
    this.note,
  });

  Attendance copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? date,
    AttendanceStatus? status,
    String? note,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'date': date,
      'status': status.name,
      'note': note,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Attendance.fromMap(Map<String, dynamic> map) {
    AttendanceStatus parsedStatus = AttendanceStatus.present;
    final statusStr = map['status'] as String?;
    if (statusStr == 'absent') parsedStatus = AttendanceStatus.absent;
    if (statusStr == 'excused') parsedStatus = AttendanceStatus.excused;

    return Attendance(
      id: (map['id'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      courseId: (map['courseId'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      status: parsedStatus,
      note: map['note'] as String?,
    );
  }

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance.fromMap(json);
}

/// Registro individual de un alumno dentro de una sesión histórica de clase
class StudentAttendanceItem {
  final String studentId;
  final String studentName;
  final AttendanceStatus status;
  final String? note;

  const StudentAttendanceItem({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'status': status.name,
      'note': note,
    };
  }

  factory StudentAttendanceItem.fromMap(Map<String, dynamic> map) {
    AttendanceStatus parsedStatus = AttendanceStatus.present;
    final statusStr = map['status'] as String?;
    if (statusStr == 'absent') parsedStatus = AttendanceStatus.absent;
    if (statusStr == 'excused') parsedStatus = AttendanceStatus.excused;

    return StudentAttendanceItem(
      studentId: (map['studentId'] as String?) ?? '',
      studentName: (map['studentName'] as String?) ?? '',
      status: parsedStatus,
      note: map['note'] as String?,
    );
  }

  factory StudentAttendanceItem.fromJson(Map<String, dynamic> json) =>
      StudentAttendanceItem.fromMap(json);
}

/// Registro completo e histórico de una clase impartida
class ClassAttendanceSession {
  final String id;
  final String courseId;
  final String date; // YYYY-MM-DD
  final String startTime;
  final String endTime;
  final List<StudentAttendanceItem> students;
  final DateTime createdAt;

  const ClassAttendanceSession({
    required this.id,
    required this.courseId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.students,
    required this.createdAt,
  });

  int get presentCount =>
      students.where((s) => s.status == AttendanceStatus.present).length;

  int get absentCount =>
      students.where((s) => s.status == AttendanceStatus.absent || s.status == AttendanceStatus.excused).length;

  List<StudentAttendanceItem> get presentStudents =>
      students.where((s) => s.status == AttendanceStatus.present).toList();

  List<StudentAttendanceItem> get absentStudents =>
      students.where((s) => s.status == AttendanceStatus.absent || s.status == AttendanceStatus.excused).toList();

  /// Fecha en formato legible en español: "Lunes 7 de octubre de 2026"
  String get formattedDate {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    final year = int.tryParse(parts[0]) ?? 2026;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    final dt = DateTime(year, month, day);

    const dayNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    const monthNames = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    final dayName = dayNames[(dt.weekday - 1).clamp(0, 6)];
    final monthName = monthNames[(month - 1).clamp(0, 11)];

    return '$dayName $day de $monthName de $year';
  }

  String get formattedTimeRange {
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      return '$startTime - $endTime';
    }
    return startTime.isNotEmpty ? startTime : 'Horario de clase';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'students': students.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory ClassAttendanceSession.fromMap(Map<String, dynamic> map) {
    final List<StudentAttendanceItem> parsedStudents = [];
    final rawStudents = map['students'];
    if (rawStudents is List) {
      for (final item in rawStudents) {
        if (item is Map<String, dynamic>) {
          parsedStudents.add(StudentAttendanceItem.fromMap(item));
        } else if (item is Map) {
          parsedStudents.add(
            StudentAttendanceItem.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return ClassAttendanceSession(
      id: (map['id'] as String?) ?? '',
      courseId: (map['courseId'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      startTime: (map['startTime'] as String?) ?? '',
      endTime: (map['endTime'] as String?) ?? '',
      students: parsedStudents,
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  factory ClassAttendanceSession.fromJson(Map<String, dynamic> json) =>
      ClassAttendanceSession.fromMap(json);
}
