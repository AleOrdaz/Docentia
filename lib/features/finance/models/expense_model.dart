class Expense {
  final String id;
  final String teacherId;
  final String description;
  final double amount;
  final String date; // YYYY-MM-DD
  final String category;
  final String? courseId;

  const Expense({
    required this.id,
    required this.teacherId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.courseId,
  });

  Expense copyWith({
    String? id,
    String? teacherId,
    String? description,
    double? amount,
    String? date,
    String? category,
    String? courseId,
  }) {
    return Expense(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      courseId: courseId ?? this.courseId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'description': description,
      'amount': amount,
      'date': date,
      'category': category,
      'courseId': courseId,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Expense.fromMap(Map<String, dynamic> map) {
    final rawCourse = (map['courseId'] as String?)?.trim();
    return Expense(
      id: (map['id'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Materiales',
      courseId: rawCourse == null || rawCourse.isEmpty ? null : rawCourse,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) => Expense.fromMap(json);
}
