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

    final textParam = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    
    // 1. Probar deep link nativo de WhatsApp
    final nativeUri = Uri.parse('whatsapp://send?phone=$cleanPhone$textParam');
    if (await canLaunchUrl(nativeUri)) {
      return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    }

    // 2. Fallback universal vía HTTPS (wa.me)
    final webUri = Uri.parse('https://wa.me/$cleanPhone$textParam');
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }
}
