import 'package:intl/intl.dart';

enum PaymentStatus {
  paid,
  pending,
  upcoming,
  overdue,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.paid:
        return 'Pagado';
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.upcoming:
        return 'Próximo a vencer';
      case PaymentStatus.overdue:
        return 'Vencido';
    }
  }
}

enum DueDateOption {
  startOfMonth, // 1 del mes
  endOfMonth,   // Último día del mes (28/29/30/31)
}

extension DueDateOptionExtension on DueDateOption {
  String get displayName {
    switch (this) {
      case DueDateOption.startOfMonth:
        return 'Inicio de mes';
      case DueDateOption.endOfMonth:
        return 'Fin de mes';
    }
  }
}

class Payment {
  final String id;
  final String studentId;
  final String courseId;
  final String period; // Ej: "Octubre 2026"
  final int periodMonth; // 1 - 12
  final int periodYear;  // Ej: 2026
  final double amount;
  final String dueDate; // Formato YYYY-MM-DD
  final DueDateOption dueOption;
  final PaymentStatus status;
  final DateTime? paidAt;
  final double? paidAmount;

  const Payment({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.period = 'Mensualidad',
    this.periodMonth = 10,
    this.periodYear = 2026,
    required this.amount,
    required this.dueDate,
    this.dueOption = DueDateOption.endOfMonth,
    required this.status,
    this.paidAt,
    this.paidAmount,
  });

  /// Clave única de negocio por Alumno + Curso + Año + Mes
  String get periodKey => '${studentId}_${courseId}_${periodYear}_$periodMonth';

  /// Calcula la fecha exacta de vencimiento considerando fin de mes y años bisiestos
  static String calculateDueDate(int year, int month, DueDateOption option) {
    final safeMonth = month.clamp(1, 12);
    if (option == DueDateOption.startOfMonth) {
      return '$year-${safeMonth.toString().padLeft(2, '0')}-01';
    } else {
      // DateTime con día 0 en el mes siguiente obtiene el último día del mes deseado
      final lastDay = DateTime(year, safeMonth + 1, 0).day;
      return '$year-${safeMonth.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    }
  }

  /// Nombre del periodo según el idioma activo (ej. "Octubre 2026" / "October 2026").
  static String formatPeriodName(int year, int month, [String? locale]) {
    final safeMonth = month.clamp(1, 12);
    final raw = DateFormat.MMMM(locale).format(DateTime(year, safeMonth, 1));
    final label = raw.isEmpty
        ? '$safeMonth'
        : '${raw[0].toUpperCase()}${raw.substring(1)}';
    return '$label $year';
  }

  Payment copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? period,
    int? periodMonth,
    int? periodYear,
    double? amount,
    String? dueDate,
    DueDateOption? dueOption,
    PaymentStatus? status,
    DateTime? paidAt,
    double? paidAmount,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      period: period ?? this.period,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      dueOption: dueOption ?? this.dueOption,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'period': period,
      'periodMonth': periodMonth,
      'periodYear': periodYear,
      'amount': amount,
      'dueDate': dueDate,
      'dueOption': dueOption.name,
      'status': status.name,
      'paidAt': paidAt?.toIso8601String(),
      'paidAmount': paidAmount,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Payment.fromMap(Map<String, dynamic> map) {
    PaymentStatus parsedStatus = PaymentStatus.pending;
    final statusStr = map['status'] as String?;
    if (statusStr == 'paid') parsedStatus = PaymentStatus.paid;
    if (statusStr == 'upcoming') parsedStatus = PaymentStatus.upcoming;
    if (statusStr == 'overdue') parsedStatus = PaymentStatus.overdue;

    final dueOptionStr = map['dueOption'] as String?;
    final parsedDueOption = dueOptionStr == 'startOfMonth'
        ? DueDateOption.startOfMonth
        : DueDateOption.endOfMonth;

    final dueDate = (map['dueDate'] as String?) ?? '';

    // Extraer periodo año y mes con valores consistentes
    int pYear = (map['periodYear'] as num?)?.toInt() ?? DateTime.now().year;
    int pMonth = (map['periodMonth'] as num?)?.toInt() ?? DateTime.now().month;

    if (map['periodYear'] == null || map['periodMonth'] == null) {
      final parts = dueDate.split('-');
      if (parts.length >= 2) {
        pYear = int.tryParse(parts[0]) ?? pYear;
        pMonth = int.tryParse(parts[1]) ?? pMonth;
      }
    }

    final periodStr = (map['period'] as String?) ?? formatPeriodName(pYear, pMonth);
    final paidAtRaw = map['paidAt'] as String?;

    return Payment(
      id: (map['id'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      courseId: (map['courseId'] as String?) ?? '',
      period: periodStr,
      periodMonth: pMonth,
      periodYear: pYear,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: dueDate.isNotEmpty ? dueDate : calculateDueDate(pYear, pMonth, parsedDueOption),
      dueOption: parsedDueOption,
      status: parsedStatus,
      paidAt: paidAtRaw != null ? DateTime.tryParse(paidAtRaw) : null,
      paidAmount: (map['paidAmount'] as num?)?.toDouble(),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) => Payment.fromMap(json);
}
