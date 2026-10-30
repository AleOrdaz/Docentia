import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/certificate_model.dart';

class _Fonts {
  const _Fonts({
    required this.display,
    required this.displayBold,
    required this.ornate,
    required this.body,
    required this.bodyBold,
    required this.bodyItalic,
    required this.script,
  });

  final pw.Font display;
  final pw.Font displayBold;
  final pw.Font ornate;
  final pw.Font body;
  final pw.Font bodyBold;
  final pw.Font bodyItalic;
  final pw.Font script;
}

class CertificatePdfService {
  Future<Uint8List> build({
    required List<IssuedCertificate> certificates,
    required CertificateCopy copy,
    required String teacherName,
    PdfColor? accent,
  }) async {
    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final fonts = _Fonts(
      display: await PdfGoogleFonts.cinzelRegular(),
      displayBold: await PdfGoogleFonts.cinzelBold(),
      ornate: await PdfGoogleFonts.cinzelDecorativeBold(),
      body: await PdfGoogleFonts.libreBaskervilleRegular(),
      bodyBold: await PdfGoogleFonts.libreBaskervilleBold(),
      bodyItalic: await PdfGoogleFonts.libreBaskervilleItalic(),
      script: await PdfGoogleFonts.greatVibesRegular(),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fonts.body,
        bold: fonts.bodyBold,
        italic: fonts.bodyItalic,
        boldItalic: fonts.bodyItalic,
      ),
    );
    final primary = accent ?? const PdfColor.fromInt(0xFF00236F);

    for (final certificate in certificates) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(14),
          build: (context) => _page(
            certificate: certificate,
            copy: copy,
            teacherName: teacherName,
            logo: logo,
            primary: primary,
            fonts: fonts,
          ),
        ),
      );
    }

    return doc.save();
  }

  pw.Widget _page({
    required IssuedCertificate certificate,
    required CertificateCopy copy,
    required String teacherName,
    required pw.MemoryImage? logo,
    required PdfColor primary,
    required _Fonts fonts,
  }) {
    switch (certificate.style) {
      case CertificateStyle.classic:
        return _classic(certificate, copy, teacherName, logo, primary, fonts);
      case CertificateStyle.modern:
        return _modern(certificate, copy, teacherName, logo, primary, fonts);
      case CertificateStyle.elegant:
        return _elegant(certificate, copy, teacherName, logo, fonts);
    }
  }

  pw.Widget _classic(
    IssuedCertificate certificate,
    CertificateCopy copy,
    String teacherName,
    pw.MemoryImage? logo,
    PdfColor primary,
    _Fonts fonts,
  ) {
    const gold = PdfColor.fromInt(0xFFC4A35A);
    const ivory = PdfColor.fromInt(0xFFFBF6EC);
    return pw.Container(
      color: ivory,
      child: pw.CustomPaint(
        painter: (canvas, size) => _paintClassicFrame(canvas, size, gold, primary),
        child: pw.Stack(
          children: [
            _watermark(copy.brand, primary, fonts),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(44, 28, 44, 24),
              child: pw.Column(
                children: [
                  _brandRow(copy.brand, logo, primary, fonts),
                  pw.SizedBox(height: 10),
                  _ornament(gold, width: 200),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    copy.title.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.ornate,
                      fontSize: 28,
                      color: primary,
                      letterSpacing: 2.2,
                    ),
                  ),
                  pw.Spacer(flex: 2),
                  pw.Text(
                    copy.confers,
                    style: pw.TextStyle(
                      font: fonts.bodyItalic,
                      fontSize: 16,
                      color: PdfColors.grey700,
                      wordSpacing: 1.6,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    certificate.studentName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.script,
                      fontSize: 52,
                      color: primary,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  _ornament(gold, width: 220),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    copy.body,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.body,
                      fontSize: 16,
                      color: PdfColors.grey800,
                      wordSpacing: 1.6,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    certificate.courseName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.bodyItalic,
                      fontSize: 22,
                      color: primary,
                    ),
                  ),
                  pw.Spacer(flex: 3),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Expanded(
                        child: _signatureBlock(
                          copy.issuedOn,
                          '${copy.folioLabel} ${certificate.folio}',
                          primary,
                          fonts,
                          alignEnd: false,
                        ),
                      ),
                      _seal(primary, gold, fonts, certificate.issuedAt.year),
                      pw.Expanded(
                        child: _signatureBlock(
                          teacherName,
                          copy.teacherLabel,
                          primary,
                          fonts,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _modern(
    IssuedCertificate certificate,
    CertificateCopy copy,
    String teacherName,
    pw.MemoryImage? logo,
    PdfColor primary,
    _Fonts fonts,
  ) {
    const slate = PdfColor.fromInt(0xFF111827);
    const gold = PdfColor.fromInt(0xFFC4A35A);
    return pw.Container(
      color: PdfColors.white,
      child: pw.CustomPaint(
        painter: (canvas, size) => _paintModernFrame(canvas, size, primary, gold),
        child: pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(44, 26, 32, 22),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                    child: _brandRow(
                      copy.brand,
                      logo,
                      primary,
                      fonts,
                      compact: true,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFF4F7FB),
                      border: pw.Border.all(color: primary, width: 0.7),
                    ),
                    child: pw.Text(
                      '${copy.folioLabel}  ${certificate.folio}',
                      style: pw.TextStyle(
                        font: fonts.displayBold,
                        fontSize: 10,
                        color: primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 22),
              pw.Container(width: 56, height: 4, color: primary),
              pw.SizedBox(height: 12),
              pw.Text(
                copy.title.toUpperCase(),
                style: pw.TextStyle(
                  font: fonts.displayBold,
                  fontSize: 16,
                  color: primary,
                  letterSpacing: 2.4,
                ),
              ),
              pw.Spacer(flex: 2),
              pw.Text(
                copy.confers,
                style: pw.TextStyle(
                  font: fonts.body,
                  fontSize: 16,
                  color: PdfColors.grey600,
                  wordSpacing: 1.6,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                certificate.studentName,
                style: pw.TextStyle(
                  font: fonts.displayBold,
                  fontSize: 36,
                  color: slate,
                  letterSpacing: 0.2,
                ),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 10, bottom: 16),
                width: 280,
                height: 1.2,
                color: const PdfColor.fromInt(0xFFE5E7EB),
              ),
              pw.Text(
                copy.body,
                style: pw.TextStyle(
                  font: fonts.body,
                  fontSize: 16,
                  color: PdfColors.grey800,
                  wordSpacing: 1.6,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                certificate.courseName,
                style: pw.TextStyle(
                  font: fonts.bodyBold,
                  fontSize: 20,
                  color: primary,
                ),
              ),
              pw.Spacer(flex: 3),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      copy.issuedOn,
                      style: pw.TextStyle(
                        font: fonts.body,
                        fontSize: 12,
                        color: PdfColors.grey600,
                        wordSpacing: 1.4,
                      ),
                    ),
                  ),
                  _signatureBlock(
                    teacherName,
                    copy.teacherLabel,
                    primary,
                    fonts,
                    alignEnd: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  pw.Widget _elegant(
    IssuedCertificate certificate,
    CertificateCopy copy,
    String teacherName,
    pw.MemoryImage? logo,
    _Fonts fonts,
  ) {
    const burgundy = PdfColor.fromInt(0xFF6B2D5B);
    const cream = PdfColor.fromInt(0xFFF7F0E4);
    return pw.Container(
      color: cream,
      child: pw.CustomPaint(
        painter: (canvas, size) => _paintElegantFrame(canvas, size, burgundy),
        child: pw.Stack(
          children: [
            _watermark(copy.brand, burgundy, fonts),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(44, 28, 44, 24),
              child: pw.Column(
                children: [
                  _brandRow(copy.brand, logo, burgundy, fonts),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    copy.title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.display,
                      fontSize: 26,
                      color: burgundy,
                      letterSpacing: 3.2,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _ornament(burgundy, width: 140),
                  pw.Spacer(flex: 2),
                  pw.Text(
                    copy.confers,
                    style: pw.TextStyle(
                      font: fonts.bodyItalic,
                      fontSize: 16,
                      color: PdfColors.grey700,
                      wordSpacing: 1.6,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    certificate.studentName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.script,
                      fontSize: 54,
                      color: burgundy,
                    ),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    copy.body,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.body,
                      fontSize: 16,
                      color: PdfColors.grey800,
                      wordSpacing: 1.6,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    certificate.courseName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fonts.bodyItalic,
                      fontSize: 22,
                      color: burgundy,
                    ),
                  ),
                  pw.Spacer(flex: 3),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Expanded(
                        child: _signatureBlock(
                          copy.issuedOn,
                          '${copy.folioLabel} ${certificate.folio}',
                          burgundy,
                          fonts,
                          alignEnd: false,
                        ),
                      ),
                      _seal(burgundy, burgundy, fonts, certificate.issuedAt.year),
                      pw.Expanded(
                        child: _signatureBlock(
                          teacherName,
                          copy.teacherLabel,
                          burgundy,
                          fonts,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _watermark(String brand, PdfColor color, _Fonts fonts) {
    return pw.Positioned.fill(
      child: pw.Center(
        child: pw.Opacity(
          opacity: 0.045,
          child: pw.Transform.rotate(
            angle: -0.42,
            child: pw.Text(
              brand.toUpperCase(),
              style: pw.TextStyle(
                font: fonts.ornate,
                fontSize: 48,
                color: color,
                letterSpacing: 6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _brandRow(
    String brand,
    pw.MemoryImage? logo,
    PdfColor color,
    _Fonts fonts, {
    bool compact = false,
  }) {
    return pw.Row(
      mainAxisAlignment:
          compact ? pw.MainAxisAlignment.start : pw.MainAxisAlignment.center,
      children: [
        if (logo != null) ...[
          pw.Image(logo, width: compact ? 22 : 30, height: compact ? 22 : 30),
          pw.SizedBox(width: 10),
        ],
        pw.Text(
          brand.toUpperCase(),
          style: pw.TextStyle(
            font: fonts.displayBold,
            fontSize: compact ? 12 : 14,
            color: color,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  pw.Widget _ornament(PdfColor color, {double width = 150}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(width: width / 2 - 14, height: 0.55, color: color),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7),
          child: pw.Transform.rotateBox(
            angle: math.pi / 4,
            child: pw.Container(width: 6.5, height: 6.5, color: color),
          ),
        ),
        pw.Container(width: width / 2 - 14, height: 0.55, color: color),
      ],
    );
  }

  pw.Widget _seal(
    PdfColor color,
    PdfColor ring,
    _Fonts fonts,
    int year,
  ) {
    return pw.CustomPaint(
      painter: (canvas, size) => _paintSeal(canvas, size, ring),
      child: pw.SizedBox(
        width: 96,
        height: 96,
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'DOC',
                style: pw.TextStyle(
                  font: fonts.displayBold,
                  fontSize: 13,
                  color: color,
                  letterSpacing: 1.8,
                ),
              ),
              pw.Text(
                '$year',
                style: pw.TextStyle(
                  font: fonts.body,
                  fontSize: 11,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pw.Widget _signatureBlock(
    String title,
    String subtitle,
    PdfColor color,
    _Fonts fonts, {
    required bool alignEnd,
  }) {
    return pw.Column(
      crossAxisAlignment:
          alignEnd ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 190,
          height: 1,
          color: color,
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          width: 190,
          height: 0.4,
          color: PdfColor(color.red, color.green, color.blue, 0.45),
        ),
        pw.SizedBox(height: 7),
        pw.Text(
          title,
          textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            font: fonts.bodyBold,
            fontSize: 13,
            color: color,
            wordSpacing: 1.4,
          ),
        ),
        pw.Text(
          subtitle,
          style: pw.TextStyle(
            font: fonts.body,
            fontSize: 11,
            color: PdfColors.grey600,
            wordSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  void _paintClassicFrame(
    PdfGraphics canvas,
    PdfPoint size,
    PdfColor gold,
    PdfColor navy,
  ) {
    _strokeRect(canvas, size, 5.5, 3.3, gold);
    _strokeRect(canvas, size, 11.5, 1.15, navy);
    _strokeRect(canvas, size, 15.8, 0.55, gold);

    canvas
      ..setStrokeColor(PdfColor(gold.red, gold.green, gold.blue, 0.28))
      ..setLineWidth(0.32);
    for (var i = 0; i < 6; i++) {
      final inset = 21.0 + i * 2.2;
      canvas.drawRRect(
        inset,
        inset,
        size.x - inset * 2,
        size.y - inset * 2,
        9,
        9,
      );
    }
    canvas.strokePath();

    const inset = 22.0;
    const len = 30.0;
    _cornerL(canvas, inset, size.y - inset, 1, -1, len, gold);
    _cornerL(canvas, size.x - inset, size.y - inset, -1, -1, len, gold);
    _cornerL(canvas, inset, inset, 1, 1, len, gold);
    _cornerL(canvas, size.x - inset, inset, -1, 1, len, gold);

    _flourish(canvas, inset + 10, size.y - inset - 10, 1, -1, gold);
    _flourish(canvas, size.x - inset - 10, size.y - inset - 10, -1, -1, gold);
    _flourish(canvas, inset + 10, inset + 10, 1, 1, gold);
    _flourish(canvas, size.x - inset - 10, inset + 10, -1, 1, gold);

    _rosette(canvas, size.x / 2, size.y - 15.8, gold);
    _rosette(canvas, size.x / 2, 15.8, gold);
    _rosette(canvas, 15.8, size.y / 2, gold);
    _rosette(canvas, size.x - 15.8, size.y / 2, gold);
  }

  void _paintModernFrame(
    PdfGraphics canvas,
    PdfPoint size,
    PdfColor primary,
    PdfColor gold,
  ) {
    canvas
      ..setFillColor(primary)
      ..drawRect(0, 0, 14, size.y)
      ..fillPath();
    canvas
      ..setFillColor(gold)
      ..drawRect(14, 0, 3.2, size.y)
      ..fillPath();
    canvas
      ..setFillColor(const PdfColor.fromInt(0xFFDCE6F5))
      ..drawRect(17.2, size.y - 7, size.x - 17.2, 7)
      ..fillPath();

    canvas
      ..setStrokeColor(PdfColor(primary.red, primary.green, primary.blue, 0.08))
      ..setLineWidth(0.5);
    for (var i = 0; i < 5; i++) {
      canvas.drawEllipse(size.x - 70, size.y / 2, 88.0 - i * 12, 88.0 - i * 12);
    }
    canvas.strokePath();
  }

  void _paintElegantFrame(PdfGraphics canvas, PdfPoint size, PdfColor color) {
    _strokeRect(canvas, size, 8, 0.95, color);
    _strokeRect(canvas, size, 13.5, 0.45, color);
    _strokeRect(canvas, size, 17, 0.3, PdfColor(color.red, color.green, color.blue, 0.45));

    const inset = 24.0;
    const len = 26.0;
    _cornerL(canvas, inset, size.y - inset, 1, -1, len, color);
    _cornerL(canvas, size.x - inset, size.y - inset, -1, -1, len, color);
    _cornerL(canvas, inset, inset, 1, 1, len, color);
    _cornerL(canvas, size.x - inset, inset, -1, 1, len, color);

    _flourish(canvas, inset + 8, size.y - inset - 8, 1, -1, color);
    _flourish(canvas, size.x - inset - 8, size.y - inset - 8, -1, -1, color);
    _flourish(canvas, inset + 8, inset + 8, 1, 1, color);
    _flourish(canvas, size.x - inset - 8, inset + 8, -1, 1, color);
  }

  void _paintSeal(PdfGraphics canvas, PdfPoint size, PdfColor ring) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = size.x / 2 - 3;
    canvas
      ..setStrokeColor(ring)
      ..setLineWidth(1.7)
      ..drawEllipse(cx, cy, r, r)
      ..strokePath()
      ..setLineWidth(0.55)
      ..drawEllipse(cx, cy, r - 5.5, r - 5.5)
      ..strokePath();

    canvas.setLineWidth(0.7);
    for (var i = 0; i < 28; i++) {
      final a = i * math.pi * 2 / 28;
      canvas.drawLine(
        cx + math.cos(a) * (r - 1.2),
        cy + math.sin(a) * (r - 1.2),
        cx + math.cos(a) * (r + 1.4),
        cy + math.sin(a) * (r + 1.4),
      );
    }
    canvas.strokePath();
  }

  void _strokeRect(
    PdfGraphics canvas,
    PdfPoint size,
    double inset,
    double width,
    PdfColor color,
  ) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(width)
      ..drawRect(inset, inset, size.x - inset * 2, size.y - inset * 2)
      ..strokePath();
  }

  void _cornerL(
    PdfGraphics canvas,
    double x,
    double y,
    double dx,
    double dy,
    double len,
    PdfColor color,
  ) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(1.35)
      ..moveTo(x, y + dy * len)
      ..lineTo(x, y)
      ..lineTo(x + dx * len, y)
      ..strokePath()
      ..setLineWidth(0.55)
      ..moveTo(x + dx * 5, y + dy * (len * 0.62))
      ..lineTo(x + dx * 5, y + dy * 5)
      ..lineTo(x + dx * (len * 0.62), y + dy * 5)
      ..strokePath();
  }

  void _flourish(
    PdfGraphics canvas,
    double x,
    double y,
    double dx,
    double dy,
    PdfColor color,
  ) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(0.55)
      ..moveTo(x, y)
      ..curveTo(
        x + dx * 10,
        y + dy * 2,
        x + dx * 16,
        y + dy * 14,
        x + dx * 8,
        y + dy * 18,
      )
      ..moveTo(x, y)
      ..curveTo(
        x + dx * 4,
        y + dy * 8,
        x + dx * 18,
        y + dy * 6,
        x + dx * 20,
        y + dy * 2,
      )
      ..strokePath();
  }

  void _rosette(PdfGraphics canvas, double x, double y, PdfColor color) {
    const s = 3.4;
    canvas
      ..setFillColor(color)
      ..moveTo(x, y + s)
      ..lineTo(x + s, y)
      ..lineTo(x, y - s)
      ..lineTo(x - s, y)
      ..closePath()
      ..fillPath();
  }
}
