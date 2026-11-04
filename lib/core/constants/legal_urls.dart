/// URLs legales / soporte para App Store y Play Store.
///
/// HTML listo en `/legal` del repo. Tras publicarlo en HTTPS, cambia [siteBase].
/// Guía: `legal/README.md`.
class LegalUrls {
  LegalUrls._();

  /// Base pública HTTPS (GitHub Pages, Netlify, etc.).
  /// Ejemplo: `https://tu-usuario.github.io/docentia-legal`
  static const String siteBase = 'https://docentia-809b0.web.app';

  static const String privacyPolicy = '$siteBase/privacy.html';
  static const String termsOfUse = '$siteBase/terms.html';
  static const String support = '$siteBase/support.html';

  /// Play exige un recurso web externo para solicitar borrado de cuenta.
  static const String accountDeletion = '$siteBase/account-deletion.html';

  /// Gestión de suscripciones en cada tienda.
  static const String appleSubscriptions =
      'https://apps.apple.com/account/subscriptions';
  static const String googlePlaySubscriptions =
      'https://play.google.com/store/account/subscriptions';
}
