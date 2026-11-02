import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

/// Abre el selector nativo de contactos y devuelve un teléfono móvil.
class ContactPickerService {
  ContactPickerService._();

  static final FlutterNativeContactPicker _picker = FlutterNativeContactPicker();

  static Future<String?> pickPhoneNumber() async {
    final contact = await _picker.selectPhoneNumber();
    if (contact == null) return null;

    final phones = contact.phoneNumbers;
    final raw = contact.selectedPhoneNumber ??
        (phones != null && phones.isNotEmpty ? phones.first : null);
    final phone = raw?.trim() ?? '';
    return phone.isEmpty ? null : phone;
  }
}
