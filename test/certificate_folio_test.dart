import 'package:docentia/features/certificates/models/certificate_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
