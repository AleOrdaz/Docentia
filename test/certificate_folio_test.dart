import 'package:docentia/features/certificates/models/certificate_model.dart';
import 'package:docentia/features/certificates/services/certificate_pdf_service.dart';
import 'package:docentia/features/certificates/widgets/certificate_diploma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('FolioGenerator', () {
    test('builds unique padded folios for a year', () {
      final first = FolioGenerator.format(sequence: 1, year: 2026);
      final second = FolioGenerator.format(sequence: 2, year: 2026);
      final later = FolioGenerator.format(sequence: 36, year: 2026);

      expect(first, 'DOC-2026-00001');
      expect(second, 'DOC-2026-00002');
      expect(later, 'DOC-2026-00010');
      expect({first, second, later}.length, 3);
    });
  });

  test('every style survives a round trip', () {
    for (final style in CertificateStyle.values) {
      final certificate = _sample(style);
      final restored = IssuedCertificate.fromMap(certificate.toMap());
      expect(restored.style, style);
    }
  });

  testWidgets('each certificate style lays out', (tester) async {
    for (final style in CertificateStyle.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 480,
              height: 480 / 1.414,
              child: CertificateDiploma(
                certificate: _sample(style),
                copy: const CertificateCopy(
                  brand: 'Docentia',
                  title: 'Certificado de participación',
                  confers: 'Se otorga a',
                  body: 'por haber concluido satisfactoriamente el curso',
                  issuedOn: '22 de noviembre de 2026',
                  teacherLabel: 'Docente',
                  folioLabel: 'Folio',
                ),
                teacherName: 'Antonio Varela',
                accent: const Color(0xFF00236F),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: style.name);
    }
  });

  test('pdf builds every style', () async {
    final bytes = await CertificatePdfService().build(
      certificates: [
        for (final style in CertificateStyle.values) _sample(style),
      ],
      copy: const CertificateCopy(
        brand: 'Docentia',
        title: 'Certificado de participación',
        confers: 'Se otorga a',
        body: 'por haber concluido satisfactoriamente el curso',
        issuedOn: '22 de noviembre de 2026',
        teacherLabel: 'Docente',
        folioLabel: 'Folio',
      ),
      teacherName: 'Antonio Varela',
    );
    expect(bytes.length, greaterThan(1000));
  });
}

IssuedCertificate _sample(CertificateStyle style) {
  return IssuedCertificate(
    id: 'cert-1',
    folio: 'DOC-2026-00001',
    courseId: 'course',
    studentId: 'student',
    studentName: 'Ana María López Hernández',
    courseName: 'Matemáticas avanzadas',
    type: CertificateType.completion,
    style: style,
    issuedAt: DateTime(2026, 11, 22),
  );
}
