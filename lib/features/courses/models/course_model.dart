import 'package:flutter/widgets.dart';

enum PaymentSchedule {
  firstHalf,
  endOfMonth,
}

/// Modalidad para distinguir grupos de servicios de atención individual.
enum CourseType { group, individual }

/// Frecuencia acordada para cobrar. Los cobros no mensuales se registran manualmente.
enum BillingFrequency { monthly, perClass, weekly, biweekly }

extension PaymentScheduleExtension on PaymentSchedule {
  String get displayName {
    switch (this) {
      case PaymentSchedule.firstHalf:
        return 'A mitad de mes';
      case PaymentSchedule.endOfMonth:
        return 'Fin de mes';
    }
  }

  String getLocalizedName(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    switch (this) {
      case PaymentSchedule.firstHalf:
        return isEn ? 'Mid-month (day 15)' : 'A mitad de mes (día 15)';
      case PaymentSchedule.endOfMonth:
        return isEn ? 'End of month (last day)' : 'Fin de mes (último día)';
    }
  }
}

T _enumValue<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((value) => value.name == name, orElse: () => fallback);

class CourseClassSchedule {
  final int weekday;
  final String startTime;
  final String endTime;

  const CourseClassSchedule({
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() => {
        'weekday': weekday,
        'startTime': startTime,
        'endTime': endTime,
      };

  factory CourseClassSchedule.fromMap(Map<String, dynamic> map) {
    return CourseClassSchedule(
      weekday: (map['weekday'] as num?)?.toInt() ?? 1,
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
    );
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
  final List<CourseClassSchedule> classSchedules;
  final String duration;
  final int currentSession;
  final int totalSessions;
  final double cost;
  final int capacity;
  final PaymentSchedule paymentSchedule;
  final String iconKey;
  final bool active;
  final DateTime createdAt;
  final CourseType type;
  final BillingFrequency billingFrequency;

  const Course({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.schedule,
    required this.classDays,
    required this.startTime,
    required this.endTime,
    this.classSchedules = const [],
    required this.duration,
    required this.currentSession,
    required this.totalSessions,
    required this.cost,
    required this.capacity,
    required this.paymentSchedule,
    this.iconKey = 'robotics',
    required this.active,
    required this.createdAt,
    this.type = CourseType.group,
    this.billingFrequency = BillingFrequency.monthly,
  });

  /// Determina si una fecha específica (o la fecha actual) es un día de clase para este curso
  bool isClassDay([DateTime? date]) {
    final d = date ?? DateTime.now();
    final days = effectiveClassDays;
    if (days.isEmpty) return true;
    return days.contains(d.weekday);
  }

  List<int> get effectiveClassDays {
    final days = classSchedules.isEmpty
        ? classDays.toSet().toList()
        : effectiveClassSchedules.map((item) => item.weekday).toSet().toList();
    return days..sort();
  }

  /// Horarios por día, con fallback para cursos creados antes de este modelo.
  List<CourseClassSchedule> get effectiveClassSchedules {
    if (classSchedules.isNotEmpty) {
      final byWeekday = <int, CourseClassSchedule>{};
      for (final item in classSchedules) {
        if (item.weekday >= 1 && item.weekday <= 7) {
          byWeekday[item.weekday] = item;
        }
      }
      return byWeekday.values.toList()
        ..sort((a, b) => a.weekday.compareTo(b.weekday));
    }
    return classDays
        .map((weekday) => CourseClassSchedule(
              weekday: weekday,
              startTime: startTime,
              endTime: endTime,
            ))
        .toList();
  }

  CourseClassSchedule? scheduleForDay(int weekday) {
    for (final item in effectiveClassSchedules) {
      if (item.weekday == weekday) return item;
    }
    return null;
  }

  bool get hasUniformScheduleEveryDay {
    final days = effectiveClassDays;
    final schedules = effectiveClassSchedules;
    if (days.length != 7 || schedules.length != 7) return false;
    final first = schedules.first;
    return schedules.every((item) =>
        item.startTime == first.startTime && item.endTime == first.endTime);
  }

  /// Próximo día de clase, incluyendo hoy si todavía aplica.
  DateTime? nextClassDate([DateTime? from]) {
    final start = from ?? DateTime.now();
    final day = DateTime(start.year, start.month, start.day);
    for (var i = 0; i < 14; i++) {
      final candidate = day.add(Duration(days: i));
      if (isClassDay(candidate)) return candidate;
    }
    return null;
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
    final sorted = effectiveClassDays;
    if (sorted.isEmpty) return 'Sin días asignados';
    if (sorted.length == 1) return shortNames[sorted.first] ?? 'Día';
    final prefix = sorted
        .sublist(0, sorted.length - 1)
        .map((d) => shortNames[d] ?? '')
        .join(', ');
    return '$prefix y ${shortNames[sorted.last] ?? ''}';
  }

  String getLocalizedFormattedDays(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final shortNames = isEn
        ? {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'}
        : {
            1: 'Lun',
            2: 'Mar',
            3: 'Mié',
            4: 'Jue',
            5: 'Vie',
            6: 'Sáb',
            7: 'Dom'
          };
    final sorted = effectiveClassDays;
    if (sorted.isEmpty) return isEn ? 'No days assigned' : 'Sin días asignados';
    if (sorted.length == 1) {
      return shortNames[sorted.first] ?? (isEn ? 'Day' : 'Día');
    }
    final prefix = sorted
        .sublist(0, sorted.length - 1)
        .map((d) => shortNames[d] ?? '')
        .join(', ');
    final conjunction = isEn ? '&' : 'y';
    return '$prefix $conjunction ${shortNames[sorted.last] ?? ''}';
  }

  /// Horario formateado estructurado: Días + Horas
  String get formattedSchedule {
    return _formatScheduleGroups(isEnglish: false);
  }

  String getLocalizedSchedule(BuildContext context) {
    return _formatScheduleGroups(
      isEnglish: Localizations.localeOf(context).languageCode == 'en',
    );
  }

  String getLocalizedHeaderSchedule(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (hasUniformScheduleEveryDay) {
      final range = _scheduleRange(effectiveClassSchedules.first);
      final everyDay = isEnglish ? 'Every day' : 'Todos los días';
      return _keepMeridiemTogether('$everyDay · $range');
    }

    final groupedSchedules = <String, List<int>>{};
    for (final item in effectiveClassSchedules) {
      groupedSchedules
          .putIfAbsent(_scheduleRange(item), () => [])
          .add(item.weekday);
    }
    if (groupedSchedules.isEmpty) {
      return isEnglish ? 'No days assigned' : 'Sin días asignados';
    }

    final lines = <String>[];
    for (final entry in groupedSchedules.entries) {
      final weekdays = entry.value.toSet().toList()..sort();
      for (var index = 0; index < weekdays.length; index += 2) {
        final pairEnd = (index + 2).clamp(0, weekdays.length).toInt();
        final dayLabel = _formatWeekdays(
          weekdays.sublist(index, pairEnd),
          isEnglish,
        );
        final separator = lines.isEmpty ? '' : '· ';
        lines.add('$separator$dayLabel · ${entry.key}');
      }
    }
    return _keepMeridiemTogether(lines.join('\n'));
  }

  String _formatScheduleGroups({required bool isEnglish}) {
    final groupedDays = <String, List<int>>{};
    for (final item in effectiveClassSchedules) {
      groupedDays.putIfAbsent(_scheduleRange(item), () => []).add(item.weekday);
    }
    if (groupedDays.isEmpty) {
      return isEnglish ? 'No days assigned' : 'Sin días asignados';
    }
    final formatted = groupedDays.entries
        .map((entry) =>
            '${_formatWeekdays(entry.value, isEnglish)} ${entry.key}'.trim())
        .join(' · ');
    return _keepMeridiemTogether(formatted);
  }

  String _scheduleRange(CourseClassSchedule item) {
    if (item.startTime.isNotEmpty && item.endTime.isNotEmpty) {
      return '${item.startTime} - ${item.endTime}';
    }
    return item.startTime.isNotEmpty ? item.startTime : schedule;
  }

  String _keepMeridiemTogether(String value) {
    return value.replaceAllMapped(
      RegExp(r' (?=(?:AM|PM)\b)', caseSensitive: false),
      (_) => '\u00A0',
    );
  }

  String _formatWeekdays(List<int> weekdays, bool isEnglish) {
    const spanish = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };
    const english = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final labels = weekdays.toSet().toList()..sort();
    final names = labels.map((day) =>
        (isEnglish ? english : spanish)[day] ?? (isEnglish ? 'Day' : 'Día'));
    final joined = names.toList();
    if (joined.isEmpty) return '';
    if (joined.length == 1) return joined.first;
    final conjunction = isEnglish ? '&' : 'y';
    return '${joined.sublist(0, joined.length - 1).join(', ')} $conjunction ${joined.last}';
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
    List<CourseClassSchedule>? classSchedules,
    String? duration,
    int? currentSession,
    int? totalSessions,
    double? cost,
    int? capacity,
    PaymentSchedule? paymentSchedule,
    String? iconKey,
    bool? active,
    DateTime? createdAt,
    CourseType? type,
    BillingFrequency? billingFrequency,
  }) {
    return Course(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      schedule: schedule ?? this.schedule,
      classDays: classDays ?? this.classDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      classSchedules: classSchedules ?? this.classSchedules,
      duration: duration ?? this.duration,
      currentSession: currentSession ?? this.currentSession,
      totalSessions: totalSessions ?? this.totalSessions,
      cost: cost ?? this.cost,
      capacity: capacity ?? this.capacity,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      iconKey: iconKey ?? this.iconKey,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      billingFrequency: billingFrequency ?? this.billingFrequency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
      'schedule': schedule,
      'classDays': effectiveClassDays,
      'startTime': startTime,
      'endTime': endTime,
      'classSchedules':
          effectiveClassSchedules.map((item) => item.toMap()).toList(),
      'duration': duration,
      'currentSession': currentSession,
      'totalSessions': totalSessions,
      'cost': cost,
      'capacity': capacity,
      'paymentSchedule': paymentSchedule.name,
      'iconKey': iconKey,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'billingFrequency': billingFrequency.name,
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

    final startTime = (map['startTime'] as String?) ?? '17:00';
    final endTime = (map['endTime'] as String?) ?? '18:30';
    final parsedSchedules = <CourseClassSchedule>[];
    final rawSchedules = map['classSchedules'];
    if (rawSchedules is List) {
      for (final item in rawSchedules) {
        if (item is Map<String, dynamic>) {
          final parsed = CourseClassSchedule.fromMap(item);
          if (parsed.weekday >= 1 && parsed.weekday <= 7) {
            parsedSchedules.add(parsed);
          }
        } else if (item is Map) {
          final parsed = CourseClassSchedule.fromMap(
            Map<String, dynamic>.from(item),
          );
          if (parsed.weekday >= 1 && parsed.weekday <= 7) {
            parsedSchedules.add(parsed);
          }
        }
      }
    }
    if (parsedSchedules.isNotEmpty) {
      parsedDays
        ..clear()
        ..addAll(parsedSchedules.map((item) => item.weekday).toSet())
        ..sort();
    } else if (parsedDays.isEmpty) {
      // Default: Lunes y Miércoles
      parsedDays.addAll([1, 3]);
    }
    if (parsedSchedules.isEmpty) {
      parsedSchedules.addAll(parsedDays.map((weekday) => CourseClassSchedule(
            weekday: weekday,
            startTime: startTime,
            endTime: endTime,
          )));
    }

    return Course(
      id: (map['id'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      schedule: (map['schedule'] as String?) ?? '',
      classDays: parsedDays,
      startTime: startTime,
      endTime: endTime,
      classSchedules: parsedSchedules,
      duration: (map['duration'] as String?) ?? '32 sesiones',
      currentSession: (map['currentSession'] as num?)?.toInt() ?? 1,
      totalSessions: (map['totalSessions'] as num?)?.toInt() ?? 32,
      cost: (map['cost'] as num?)?.toDouble() ?? 0,
      capacity: (map['capacity'] as num?)?.toInt() ?? 30,
      paymentSchedule: (map['paymentSchedule'] as String?) == 'endOfMonth'
          ? PaymentSchedule.endOfMonth
          : PaymentSchedule.firstHalf,
      iconKey: (map['iconKey'] as String?) ?? 'robotics',
      active: (map['active'] as bool?) ?? true,
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      type: _enumValue(CourseType.values, map['type'], CourseType.group),
      billingFrequency: _enumValue(BillingFrequency.values,
          map['billingFrequency'], BillingFrequency.monthly),
    );
  }

  factory Course.fromJson(Map<String, dynamic> json) => Course.fromMap(json);
}
