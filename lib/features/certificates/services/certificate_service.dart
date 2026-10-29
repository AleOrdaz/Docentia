import '../../../core/services/storage_service.dart';
import '../../students/models/student_model.dart';
import '../models/certificate_model.dart';

class CertificateService {
  Future<List<IssuedCertificate>> issueCertificates({
    required List<Student> students,
    required String courseId,
    required String courseName,
    required CertificateType type,
    required CertificateStyle style,
  }) async {
    final issued = await StorageService.getCertificates();
    var sequence = await StorageService.getFolioSequence();
    final year = DateTime.now().year;
    final used = issued.map((item) => item.folio).toSet();
    final created = <IssuedCertificate>[];

    for (final student in students) {
      String folio;
      do {
        sequence += 1;
        folio = FolioGenerator.format(sequence: sequence, year: year);
      } while (used.contains(folio));
      used.add(folio);

      created.add(
        IssuedCertificate(
          id: 'cert-$sequence-${student.id}',
          folio: folio,
          courseId: courseId,
          studentId: student.id,
          studentName: student.fullName,
          courseName: courseName,
          type: type,
          style: style,
          issuedAt: DateTime.now(),
        ),
      );
    }

    await StorageService.saveFolioSequence(sequence);
    await StorageService.saveCertificates([...issued, ...created]);
    return created;
  }
}
