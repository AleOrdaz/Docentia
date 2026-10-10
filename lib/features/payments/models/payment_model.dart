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

class Payment {
  final String id;
  final String studentId;
  final String courseId;
  final String period; // Ej: "Octubre 2026"
  final double amount;
  final String dueDate; // Formato YYYY-MM-DD
  final PaymentStatus status;
  final DateTime? paidAt;
  final double? paidAmount;

  const Payment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.period,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAt,
    this.paidAmount,
  });

  Payment copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? period,
    double? amount,
    String? dueDate,
    PaymentStatus? status,
    DateTime? paidAt,
    double? paidAmount,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      period: period ?? this.period,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
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
      'amount': amount,
      'dueDate': dueDate,
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

    final paidAtRaw = map['paidAt'] as String?;

    return Payment(
      id: (map['id'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      courseId: (map['courseId'] as String?) ?? '',
      period: (map['period'] as String?) ?? 'Mensualidad',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: (map['dueDate'] as String?) ?? '',
      status: parsedStatus,
      paidAt: paidAtRaw != null ? DateTime.tryParse(paidAtRaw) : null,
      paidAmount: (map['paidAmount'] as num?)?.toDouble(),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) => Payment.fromMap(json);
}
