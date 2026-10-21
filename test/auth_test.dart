import 'package:flutter_test/flutter_test.dart';
import 'package:docentia/features/auth/models/teacher_model.dart';
import 'package:docentia/features/auth/utils/teacher_name.dart';
import 'package:docentia/features/auth/utils/teacher_photo.dart';

void main() {
  group('resolveTeacherName from Google', () {
    test('usa el displayName de Google cuando es un nombre de persona', () {
      final name = resolveTeacherName(
        displayName: 'María López',
        email: 'maria.lopez@gmail.com',
      );

      expect(name, 'María López');
      expect(looksLikeEmail(name), isFalse);
    });

    test('no usa el correo aunque Google lo envíe como displayName', () {
      final name = resolveTeacherName(
        displayName: 'maria.lopez@gmail.com',
        email: 'maria.lopez@gmail.com',
      );

      expect(name, isNot('maria.lopez@gmail.com'));
      expect(looksLikeEmail(name), isFalse);
      expect(name, 'Docente');
    });

    test('no usa la parte local del correo cuando falta el nombre', () {
      final name = resolveTeacherName(
        displayName: null,
        email: 'antonio.varela@gmail.com',
      );

      expect(name, isNot('antonio.varela'));
      expect(name, isNot('antonio.varela@gmail.com'));
      expect(looksLikeEmail(name), isFalse);
      expect(name, 'Docente');
    });

    test('conserva el nombre previo si Google manda el correo como displayName', () {
      final name = resolveTeacherName(
        displayName: 'antonio.varela@gmail.com',
        previousName: 'Antonio Varela',
        email: 'antonio.varela@gmail.com',
      );

      expect(name, 'Antonio Varela');
    });

    test('usa el displayName del proveedor Google si el de Firebase viene vacío', () {
      final name = resolveTeacherName(
        displayName: '  ',
        providerDisplayName: 'Ana García',
        email: 'ana.garcia@gmail.com',
      );

      expect(name, 'Ana García');
      expect(isPersonName(name, email: 'ana.garcia@gmail.com'), isTrue);
    });

    test('ignora el displayName del proveedor si también es un correo', () {
      final name = resolveTeacherName(
        displayName: null,
        providerDisplayName: 'ana.garcia@gmail.com',
        email: 'ana.garcia@gmail.com',
      );

      expect(name, 'Docente');
      expect(looksLikeEmail(name), isFalse);
    });

    test('recorta espacios y rechaza un displayName vacío', () {
      expect(
        resolveTeacherName(
          displayName: '  Pedro Ruiz  ',
          email: 'pedro@gmail.com',
        ),
        'Pedro Ruiz',
      );
      expect(
        resolveTeacherName(displayName: '', email: 'pedro@gmail.com'),
        'Docente',
      );
    });
  });

  group('isPersonName', () {
    test('distingue un nombre de un correo', () {
      expect(isPersonName('Camila Morales'), isTrue);
      expect(isPersonName('camila@docentia.edu'), isFalse);
      expect(isPersonName(''), isFalse);
      expect(isPersonName(null), isFalse);
    });
  });

  group('teacherNeedsProfileSetup', () {
    Teacher teacher({String name = 'Docente', String email = 'ana@gmail.com'}) {
      return Teacher(
        id: 't1',
        name: name,
        email: email,
        photoUrl: '',
        provider: 'google',
        createdAt: DateTime(2026, 1, 1),
      );
    }

    test('pide personalizar la cuenta si Google no trajo un nombre', () {
      expect(teacherNeedsProfileSetup(teacher()), isTrue);
      expect(
        teacherNeedsProfileSetup(teacher(name: 'ana@gmail.com')),
        isTrue,
      );
      expect(teacherNeedsProfileSetup(null), isTrue);
    });

    test('no pide personalizar si ya hay un nombre de persona', () {
      expect(
        teacherNeedsProfileSetup(teacher(name: 'Ana García')),
        isFalse,
      );
    });
  });

  group('teacherInitials', () {
    test('usa las iniciales del nombre y no del correo', () {
      expect(teacherInitials('Ana García'), 'AG');
      expect(teacherInitials('Antonio'), 'A');
      expect(teacherInitials(kFallbackTeacherName), 'D');
    });
  });
}
