class CalendarEvent {
  final String id;
  final String title;
  final String type;
  final String description;
  final String date; // YYYY-MM-DD
  final String startTime; // HH:mm
  final String? endTime; // HH:mm
  final String? location;
  final String? courseId;
  final List<String> emailRecipients;
  final String? reminder;
  final DateTime createdAt;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.type = 'exam',
    required this.description,
    required this.date,
    required this.startTime,
    this.endTime,
    this.location,
    this.courseId,
    this.emailRecipients = const [],
    this.reminder,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'courseId': courseId,
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
      type: (map['type'] as String?) ?? 'exam',
      description: (map['description'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      startTime: (map['startTime'] as String?) ?? '',
      endTime: map['endTime'] as String?,
      location: map['location'] as String?,
      courseId: map['courseId'] as String?,
      emailRecipients: recipients,
      reminder: map['reminder'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? type,
    String? description,
    String? date,
    String? startTime,
    String? endTime,
    String? location,
    String? courseId,
    List<String>? emailRecipients,
    String? reminder,
    DateTime? createdAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      courseId: courseId ?? this.courseId,
      emailRecipients: emailRecipients ?? this.emailRecipients,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
