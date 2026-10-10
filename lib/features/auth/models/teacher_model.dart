class Teacher {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String provider; // 'google' | 'apple'
  final String? bio;
  final String? phone;
  final DateTime createdAt;

  const Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.provider,
    this.bio,
    this.phone,
    required this.createdAt,
  });

  Teacher copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? provider,
    String? bio,
    String? phone,
    DateTime? createdAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider,
      'bio': bio,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      provider: (map['provider'] as String?) ?? 'google',
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher.fromMap(json);
}
