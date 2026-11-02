import 'package:docentia/core/services/whatsapp_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('URI nativa usa un solo ? y query text correcta', () {
    final uri = WhatsAppService.buildNativeUri(
      '5215512345678',
      'Hola tutor',
    );

    expect(uri.scheme, 'whatsapp');
    expect(uri.host, 'send');
    expect(uri.queryParameters['phone'], '5215512345678');
    expect(uri.queryParameters['text'], 'Hola tutor');
    expect(uri.toString().split('?').length, 2);
    expect(uri.toString(), isNot(contains('?text=')));
    expect(uri.toString(), contains('&text='));
  });

  test('URI web wa.me incluye text como query', () {
    final uri = WhatsAppService.buildWebUri('5215512345678', 'Hola');

    expect(uri.scheme, 'https');
    expect(uri.host, 'wa.me');
    expect(uri.path, '/5215512345678');
    expect(uri.queryParameters['text'], 'Hola');
    expect(uri.toString().split('?').length, 2);
  });
}
