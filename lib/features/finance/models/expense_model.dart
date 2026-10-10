class Expense {
  final String id;
  final String teacherId;
  final String description;
  final double amount;
  final String date; // YYYY-MM-DD
  final String category;

  const Expense({
    required this.id,
    required this.teacherId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'description': description,
      'amount': amount,
      'date': date,
      'category': category,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: (map['id'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Materiales',
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) => Expense.fromMap(json);
}
