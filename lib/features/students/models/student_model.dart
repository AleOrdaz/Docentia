enum TutorRelationship {
  mother,
  father,
  tutor;

  static TutorRelationship fromValue(String? value) {
    return TutorRelationship.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TutorRelationship.tutor,
    );
  }
}

class Student {
  final String id;
  final String courseId;
  final String name;
  final String lastName;
  final int age;
  final String? avatarUrl;
  final String? assignedLevel;
  final TutorRelationship tutorRelationship;
  final String tutorName;
  final String tutorPhone;
  final String tutorEmail;
  final String? secondaryPhone;
  final String? medicalNote;
  final String emergencyName;
  final TutorRelationship emergencyRelationship;
  final String emergencyPhone;
  final bool active;
  final DateTime createdAt;

  const Student({
    required this.id,
    required this.courseId,
    required this.name,
    required this.lastName,
    required this.age,
    this.avatarUrl,
    this.assignedLevel,
    this.tutorRelationship = TutorRelationship.tutor,
    required this.tutorName,
    required this.tutorPhone,
    required this.tutorEmail,
    this.secondaryPhone,
    this.medicalNote,
    this.emergencyName = '',
    this.emergencyRelationship = TutorRelationship.tutor,
    this.emergencyPhone = '',
    required this.active,
    required this.createdAt,
  });

  String get fullName => '$name $lastName';

  String get initials {
    final first = name.isNotEmpty ? name[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  Student copyWith({
    String? id,
    String? courseId,
    String? name,
    String? lastName,
    int? age,
    String? avatarUrl,
    String? assignedLevel,
    TutorRelationship? tutorRelationship,
    String? tutorName,
    String? tutorPhone,
    String? tutorEmail,
    String? secondaryPhone,
    String? medicalNote,
    String? emergencyName,
    TutorRelationship? emergencyRelationship,
    String? emergencyPhone,
    bool? active,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assignedLevel: assignedLevel ?? this.assignedLevel,
      tutorRelationship: tutorRelationship ?? this.tutorRelationship,
      tutorName: tutorName ?? this.tutorName,
      tutorPhone: tutorPhone ?? this.tutorPhone,
      tutorEmail: tutorEmail ?? this.tutorEmail,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      medicalNote: medicalNote ?? this.medicalNote,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
      'lastName': lastName,
      'age': age,
      'avatarUrl': avatarUrl,
      'assignedLevel': assignedLevel,
      'tutorRelationship': tutorRelationship.name,
      'tutorName': tutorName,
      'tutorPhone': tutorPhone,
      'tutorEmail': tutorEmail,
      'secondaryPhone': secondaryPhone,
      'medicalNote': medicalNote,
      'emergencyName': emergencyName,
      'emergencyRelationship': emergencyRelationship.name,
      'emergencyPhone': emergencyPhone,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: (map['id'] as String?) ?? '',
      courseId: (map['courseId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      lastName: (map['lastName'] as String?) ?? '',
      age: (map['age'] as num?)?.toInt() ?? 16,
      avatarUrl: map['avatarUrl'] as String?,
      assignedLevel: map['assignedLevel'] as String?,
      tutorRelationship: TutorRelationship.fromValue(map['tutorRelationship'] as String?),
      tutorName: (map['tutorName'] as String?) ?? '',
      tutorPhone: (map['tutorPhone'] as String?) ?? '',
      tutorEmail: (map['tutorEmail'] as String?) ?? '',
      secondaryPhone: map['secondaryPhone'] as String?,
      medicalNote: map['medicalNote'] as String?,
      emergencyName: (map['emergencyName'] as String?) ?? '',
      emergencyRelationship: TutorRelationship.fromValue(map['emergencyRelationship'] as String?),
      emergencyPhone: (map['emergencyPhone'] as String?) ?? '',
      active: (map['active'] as bool?) ?? true,
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) => Student.fromMap(json);
}
