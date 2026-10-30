enum CertificateType {
  completion,
  approval,
  participation,
}

enum CertificateStyle {
  classic,
  modern,
  elegant,
}

class IssuedCertificate {
  final String id;
  final String folio;
  final String courseId;
  final String studentId;
  final String studentName;
  final String courseName;
  final CertificateType type;
  final CertificateStyle style;
  final DateTime issuedAt;

  const IssuedCertificate({
    required this.id,
    required this.folio,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.courseName,
    required this.type,
    required this.style,
    required this.issuedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folio': folio,
      'courseId': courseId,
      'studentId': studentId,
      'studentName': studentName,
      'courseName': courseName,
      'type': type.name,
      'style': style.name,
      'issuedAt': issuedAt.toIso8601String(),
    };
  }

  factory IssuedCertificate.fromMap(Map<String, dynamic> map) {
    return IssuedCertificate(
      id: map['id'] as String? ?? '',
      folio: map['folio'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      courseName: map['courseName'] as String? ?? '',
      type: CertificateType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => CertificateType.completion,
      ),
      style: CertificateStyle.values.firstWhere(
        (value) => value.name == map['style'],
        orElse: () => CertificateStyle.classic,
      ),
      issuedAt: DateTime.tryParse(map['issuedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class CertificateCopy {
  final String brand;
  final String title;
  final String confers;
  final String body;
  final String issuedOn;
  final String teacherLabel;
  final String folioLabel;

  const CertificateCopy({
    required this.brand,
    required this.title,
    required this.confers,
    required this.body,
    required this.issuedOn,
    required this.teacherLabel,
    required this.folioLabel,
  });
}

class FolioGenerator {
  static String format({required int sequence, required int year}) {
    final code = sequence.toRadixString(36).toUpperCase().padLeft(5, '0');
    return 'DOC-$year-$code';
  }
}
