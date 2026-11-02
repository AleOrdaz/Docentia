import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/legal_urls.dart';

Future<bool> openLegalUrl(String url) async {
  final uri = Uri.parse(url);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> openPrivacyPolicy() => openLegalUrl(LegalUrls.privacyPolicy);

Future<bool> openTermsOfUse() => openLegalUrl(LegalUrls.termsOfUse);

Future<bool> openSupport() => openLegalUrl(LegalUrls.support);

Future<bool> openAccountDeletionWeb() =>
    openLegalUrl(LegalUrls.accountDeletion);

Future<bool> openStoreSubscriptionsManager() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return openLegalUrl(LegalUrls.appleSubscriptions);
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return openLegalUrl(LegalUrls.googlePlaySubscriptions);
  }
  return openLegalUrl(LegalUrls.support);
}
