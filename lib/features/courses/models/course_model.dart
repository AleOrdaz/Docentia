import 'package:flutter/widgets.dart';

enum PaymentSchedule {
  firstHalf,
  endOfMonth,
}

extension PaymentScheduleExtension on PaymentSchedule {
  String get displayName {
    switch (this) {
      case PaymentSchedule.firstHalf:
        return 'Primera quincena';
      case PaymentSchedule.endOfMonth:
        return 'Fin de mes';
    }
  }

  String getLocalizedName(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    switch (this) {
      case PaymentSchedule.firstHalf:
        return isEn ? 'First half (1-15)' : 'Primera quincena (1-15)';
      case PaymentSchedule.endOfMonth:
        return isEn ? 'End of month (25-30)' : 'Fin de mes (25-30)';
    }
  }
}

class Course {
  final String id;
  final String teacherId;
  final String name;
  final String schedule;
  final List<int> classDays; // 1 = Lunes, 2 = Martes, ..., 7 = Domingo
  final String startTime; // ej. "17:00" o "5:00 PM"
  final String endTime; // ej. "18:30" o "6:30 PM"
  final String duration;
  final int currentSession;
  final int totalSessions;
  final double cost;
  final int capacity;
  final PaymentSchedule paymentSchedule;
  final String iconKey;
  final bool active;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.schedule,
    required this.classDays,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.currentSession,
    required this.totalSessions,
    required this.cost,
    required this.capacity,
    required this.paymentSchedule,
    this.iconKey = 'robotics',
    required this.active,
    required this.createdAt,
  });

  /// Determina si una fecha específica (o la fecha actual) es un día de clase para este curso
  bool isClassDay([DateTime? date]) {
    final d = date ?? DateTime.now();
    if (classDays.isEmpty) return true;
    return classDays.contains(d.weekday);
  }

  /// Nombres legibles de los días seleccionados
  String get formattedDays {
    const shortNames = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };
    final sorted = List<int>.from(classDays)..sort();
    if (sorted.isEmpty) return 'Sin días asignados';
    if (sorted.length == 1) return shortNames[sorted.first] ?? 'Día';
    final prefix = sorted.sublist(0, sorted.length - 1).map((d) => shortNames[d] ?? '').join(', ');
    return '$prefix y ${shortNames[sorted.last] ?? ''}';
  }

  String getLocalizedFormattedDays(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final shortNames = isEn
        ? {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'}
        : {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom'};
    final sorted = List<int>.from(classDays)..sort();
    if (sorted.isEmpty) return isEn ? 'No days assigned' : 'Sin días asignados';
    if (sorted.length == 1) return shortNames[sorted.first] ?? (isEn ? 'Day' : 'Día');
    final prefix = sorted.sublist(0, sorted.length - 1).map((d) => shortNames[d] ?? '').join(', ');
    final conjunction = isEn ? '&' : 'y';
    return '$prefix $conjunction ${shortNames[sorted.last] ?? ''}';
  }

  /// Horario formateado estructurado: Días + Horas
  String get formattedSchedule {
    final timeStr = startTime.isNotEmpty && endTime.isNotEmpty
        ? '$startTime - $endTime'
        : (startTime.isNotEmpty ? startTime : schedule);
    return '$formattedDays $timeStr'.trim();
  }

  String getLocalizedSchedule(BuildContext context) {
    final timeStr = startTime.isNotEmpty && endTime.isNotEmpty
        ? '$startTime - $endTime'
        : (startTime.isNotEmpty ? startTime : schedule);
    return '${getLocalizedFormattedDays(context)} $timeStr'.trim();
  }

  static String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return 'Día $weekday';
    }
  }

  Course copyWith({
    String? id,
    String? teacherId,
    String? name,
    String? schedule,
    List<int>? classDays,
    String? startTime,
    String? endTime,
    String? duration,
    int? currentSession,
    int? totalSessions,
    double? cost,
    int? capacity,
    PaymentSchedule? paymentSchedule,
    String? iconKey,
    bool? active,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      schedule: schedule ?? this.schedule,
      classDays: classDays ?? this.classDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      currentSession: currentSession ?? this.currentSession,
      totalSessions: totalSessions ?? this.totalSessions,
      cost: cost ?? this.cost,
      capacity: capacity ?? this.capacity,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      iconKey: iconKey ?? this.iconKey,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
      'schedule': schedule,
      'classDays': classDays,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'currentSession': currentSession,
      'totalSessions': totalSessions,
      'cost': cost,
      'capacity': capacity,
      'paymentSchedule': paymentSchedule.name,
      'iconKey': iconKey,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Course.fromMap(Map<String, dynamic> map) {
    // Extracción segura y tipada de classDays
    final List<int> parsedDays = [];
    final rawDays = map['classDays'];
    if (rawDays is List) {
      for (final item in rawDays) {
        if (item is int) {
          parsedDays.add(item);
        } else if (item is num) {
          parsedDays.add(item.toInt());
        } else if (item is String) {
          final s = item.toLowerCase();
          if (s.contains('lun') || s == 'monday' || s == '1') {
            parsedDays.add(1);
          } else if (s.contains('mar') || s == 'tuesday' || s == '2') {
            parsedDays.add(2);
          } else if (s.contains('mi') || s == 'wednesday' || s == '3') {
            parsedDays.add(3);
          } else if (s.contains('jue') || s == 'thursday' || s == '4') {
            parsedDays.add(4);
          } else if (s.contains('vie') || s == 'friday' || s == '5') {
            parsedDays.add(5);
          } else if (s.contains('s') || s == 'saturday' || s == '6') {
            parsedDays.add(6);
          } else if (s.contains('dom') || s == 'sunday' || s == '7') {
            parsedDays.add(7);
          }
        }
      }
    }

    if (parsedDays.isEmpty) {
      // Default: Lunes y Miércoles
      parsedDays.addAll([1, 3]);
    }

    final startTime = (map['startTime'] as String?) ?? '17:00';
    final endTime = (map['endTime'] as String?) ?? '18:30';

    return Course(
      id: (map['id'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      schedule: (map['schedule'] as String?) ?? '',
      classDays: parsedDays,
      startTime: startTime,
      endTime: endTime,
      duration: (map['duration'] as String?) ?? '32 sesiones',
      currentSession: (map['currentSession'] as num?)?.toInt() ?? 1,
      totalSessions: (map['totalSessions'] as num?)?.toInt() ?? 32,
      cost: (map['cost'] as num?)?.toDouble() ?? 45000.0,
      capacity: (map['capacity'] as num?)?.toInt() ?? 30,
      paymentSchedule: (map['paymentSchedule'] as String?) == 'endOfMonth'
          ? PaymentSchedule.endOfMonth
          : PaymentSchedule.firstHalf,
      iconKey: (map['iconKey'] as String?) ?? 'robotics',
      active: (map['active'] as bool?) ?? true,
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  factory Course.fromJson(Map<String, dynamic> json) => Course.fromMap(json);
}
