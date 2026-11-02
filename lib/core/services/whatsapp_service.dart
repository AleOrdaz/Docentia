import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Abre la conversación de WhatsApp con el número del tutor
  /// Usa el esquema nativo de WhatsApp o la URL web de fallback (wa.me)
  static Future<bool> openWhatsApp({
    required String phone,
    String? message,
  }) async {
    // Sanitizar número: conservar únicamente dígitos numéricos
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) return false;

    final nativeUri = buildNativeUri(cleanPhone, message);
    if (await canLaunchUrl(nativeUri)) {
      return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    }

    final webUri = buildWebUri(cleanPhone, message);
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }

  /// URI nativa `whatsapp://send?phone=...&text=...` (un solo `?`).
  static Uri buildNativeUri(String cleanPhone, String? message) {
    return Uri(
      scheme: 'whatsapp',
      host: 'send',
      queryParameters: {
        'phone': cleanPhone,
        if (message != null) 'text': message,
      },
    );
  }

  /// URI web `https://wa.me/<phone>?text=...`.
  static Uri buildWebUri(String cleanPhone, String? message) {
    return Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$cleanPhone',
      queryParameters: {
        if (message != null) 'text': message,
      },
    );
  }
}
