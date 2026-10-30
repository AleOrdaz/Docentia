import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/certificate_model.dart';
import '../widgets/certificate_diploma.dart';

class CertificatePreviewScreen extends StatelessWidget {
  final Uint8List bytes;
  final String filename;
  final List<IssuedCertificate> certificates;
  final CertificateCopy copy;
  final String teacherName;
  final Color accent;

  const CertificatePreviewScreen({
    super.key,
    required this.bytes,
    required this.filename,
    required this.certificates,
    required this.copy,
    required this.teacherName,
    required this.accent,
  });

  Future<void> _share(BuildContext context, AppLocalizations l10n) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (_) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.certificateSaved)),
        );
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetail('$error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = AppColors.textPrimary(context);

    return Scaffold(
      backgroundColor: appPageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        title: Text(
          l10n.certificatePreviewTitle,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: certificates.length,
              controller: PageController(viewportFraction: 0.96),
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1.414,
                            child: CertificateDiploma(
                              certificate: certificate,
                              copy: copy,
                              teacherName: teacherName,
                              accent: accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        certificate.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${copy.folioLabel} ${certificate.folio}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (certificates.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l10n.certificateGenerated(certificates.length),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppPrimaryButton(
                label: l10n.certificateShare,
                icon: Icons.ios_share,
                onPressed: () => _share(context, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
