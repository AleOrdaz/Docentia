class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final String date; // YYYY-MM-DD
  final String startTime; // HH:mm
  final String? endTime; // HH:mm
  final String? location;
  final List<String> emailRecipients;
  final String? reminder;
  final DateTime createdAt;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    this.endTime,
    this.location,
    this.emailRecipients = const [],
    this.reminder,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'emailRecipients': emailRecipients,
      'reminder': reminder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    List<String> recipients = [];
    if (map['emailRecipients'] is List) {
      recipients = (map['emailRecipients'] as List).map((e) => e.toString()).toList();
    }

    return CalendarEvent(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      startTime: (map['startTime'] as String?) ?? '',
      endTime: map['endTime'] as String?,
      location: map['location'] as String?,
      emailRecipients: recipients,
      reminder: map['reminder'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? startTime,
    String? endTime,
    String? location,
    List<String>? emailRecipients,
    String? reminder,
    DateTime? createdAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      emailRecipients: emailRecipients ?? this.emailRecipients,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
