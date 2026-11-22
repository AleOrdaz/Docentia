import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/certificate_model.dart';

class CertificateDiploma extends StatelessWidget {
  final IssuedCertificate certificate;
  final CertificateCopy copy;
  final String teacherName;
  final Color accent;

  const CertificateDiploma({
    super.key,
    required this.certificate,
    required this.copy,
    required this.teacherName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return switch (certificate.style) {
      CertificateStyle.classic => _ClassicDiploma(
          certificate: certificate,
          copy: copy,
          teacherName: teacherName,
          accent: accent,
        ),
      CertificateStyle.modern => _ModernDiploma(
          certificate: certificate,
          copy: copy,
          teacherName: teacherName,
          accent: accent,
        ),
      CertificateStyle.elegant => _ElegantDiploma(
          certificate: certificate,
          copy: copy,
          teacherName: teacherName,
        ),
      CertificateStyle.academic ||
      CertificateStyle.minimal ||
      CertificateStyle.botanical ||
      CertificateStyle.imperial ||
      CertificateStyle.midnight ||
      CertificateStyle.deco ||
      CertificateStyle.ribbon ||
      CertificateStyle.parchment ||
      CertificateStyle.horizon =>
        _VarietyDiploma(
          certificate: certificate,
          copy: copy,
          teacherName: teacherName,
        ),
    };
  }
}

class _ClassicDiploma extends StatelessWidget {
  final IssuedCertificate certificate;
  final CertificateCopy copy;
  final String teacherName;
  final Color accent;

  const _ClassicDiploma({
    required this.certificate,
    required this.copy,
    required this.teacherName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC4A35A);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ColoredBox(
        color: const Color(0xFFFBF6EC),
        child: CustomPaint(
          painter: _ClassicFramePainter(gold: gold, navy: accent),
          child: Stack(
            children: [
              _Watermark(text: copy.brand, color: accent),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                child: Column(
                  children: [
                    Text(
                      copy.brand.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: accent,
                        letterSpacing: 2.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const _Ornament(color: gold),
                    const SizedBox(height: 8),
                    Text(
                      copy.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: accent,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      copy.confers,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      certificate.studentName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.greatVibes(
                        fontSize: 28,
                        color: accent,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _Ornament(color: gold, width: 88),
                    const SizedBox(height: 6),
                    Text(
                      copy.body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      certificate.courseName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: accent,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _Sign(
                            title: copy.issuedOn,
                            subtitle: '${copy.folioLabel} ${certificate.folio}',
                            color: accent,
                          ),
                        ),
                        _Seal(color: gold, year: certificate.issuedAt.year),
                        Expanded(
                          child: _Sign(
                            title: teacherName,
                            subtitle: copy.teacherLabel,
                            color: accent,
                            end: true,
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
      ),
    );
  }
}

class _ModernDiploma extends StatelessWidget {
  final IssuedCertificate certificate;
  final CertificateCopy copy;
  final String teacherName;
  final Color accent;

  const _ModernDiploma({
    required this.certificate,
    required this.copy,
    required this.teacherName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC4A35A);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ColoredBox(
        color: Colors.white,
        child: CustomPaint(
          painter: _ModernFramePainter(primary: accent, gold: gold),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        copy.brand.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: accent,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FB),
                        border: Border.all(color: accent, width: 0.7),
                      ),
                      child: Text(
                        certificate.folio,
                        style: GoogleFonts.cinzel(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(width: 36, height: 3, color: accent),
                const SizedBox(height: 8),
                Text(
                  copy.title.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  copy.confers,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  certificate.studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    height: 1.15,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 8),
                  width: 140,
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
                Text(
                  copy.body,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  certificate.courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        copy.issuedOn,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    _Sign(
                      title: teacherName,
                      subtitle: copy.teacherLabel,
                      color: accent,
                      end: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ElegantDiploma extends StatelessWidget {
  final IssuedCertificate certificate;
  final CertificateCopy copy;
  final String teacherName;

  const _ElegantDiploma({
    required this.certificate,
    required this.copy,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    const burgundy = Color(0xFF6B2D5B);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ColoredBox(
        color: const Color(0xFFF7F0E4),
        child: CustomPaint(
          painter: const _ElegantFramePainter(color: burgundy),
          child: Stack(
            children: [
              _Watermark(text: copy.brand, color: burgundy),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                child: Column(
                  children: [
                    Text(
                      copy.brand.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: burgundy,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      copy.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        color: burgundy,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const _Ornament(color: burgundy, width: 72),
                    const SizedBox(height: 10),
                    Text(
                      copy.confers,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      certificate.studentName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.greatVibes(
                        fontSize: 28,
                        color: burgundy,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      certificate.courseName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: burgundy,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _Sign(
                            title: copy.issuedOn,
                            subtitle: '${copy.folioLabel} ${certificate.folio}',
                            color: burgundy,
                          ),
                        ),
                        _Seal(color: burgundy, year: certificate.issuedAt.year),
                        Expanded(
                          child: _Sign(
                            title: teacherName,
                            subtitle: copy.teacherLabel,
                            color: burgundy,
                            end: true,
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
      ),
    );
  }
}

class _VarietyDiploma extends StatelessWidget {
  final IssuedCertificate certificate;
  final CertificateCopy copy;
  final String teacherName;

  const _VarietyDiploma({
    required this.certificate,
    required this.copy,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return switch (certificate.style) {
      CertificateStyle.academic => _academic(),
      CertificateStyle.minimal => _minimal(),
      CertificateStyle.botanical => _botanical(),
      CertificateStyle.imperial => _imperial(),
      CertificateStyle.midnight => _midnight(),
      CertificateStyle.deco => _deco(),
      CertificateStyle.ribbon => _ribbon(),
      CertificateStyle.parchment => _parchment(),
      CertificateStyle.horizon => _horizon(),
      CertificateStyle.classic ||
      CertificateStyle.modern ||
      CertificateStyle.elegant =>
        _academic(),
    };
  }

  Widget _academic() {
    const navy = Color(0xFF1B3A4B);
    const crimson = Color(0xFF8C2F39);
    const gold = Color(0xFFC4A35A);
    const paper = Color(0xFFF4F1EA);
    return _shell(
      paper: paper,
      painter: const _LineFramePainter(color: navy, outer: 0.9, inner: 0.35),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: navy,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    copy.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                    ),
                  ),
                ),
                Text(
                  '${certificate.issuedAt.year}',
                  style: GoogleFonts.cinzel(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Column(
                children: [
                  Text(
                    copy.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: crimson,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _Ornament(color: gold, width: 72),
                  const SizedBox(height: 8),
                  _copyBlock(ink: navy, course: crimson),
                  const Spacer(),
                  _footer(ink: navy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _minimal() {
    const ink = Color(0xFF1F2933);
    return _shell(
      paper: Colors.white,
      painter: const _LineFramePainter(
        color: Color(0xFFD6D3D1),
        outer: 0.7,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
        child: Column(
          children: [
            Text(
              copy.brand.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: const Color(0xFF9CA3AF),
                fontSize: 9,
                letterSpacing: 3.2,
              ),
            ),
            const Spacer(),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: ink,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              certificate.studentName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cinzel(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 1,
              color: ink,
            ),
            Text(
              certificate.courseName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cormorantGaramond(
                color: ink,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              copy.body,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFF6B7280),
                fontSize: 11,
              ),
            ),
            const Spacer(),
            _footer(ink: ink, seal: false),
          ],
        ),
      ),
    );
  }

  Widget _botanical() {
    const leaf = Color(0xFF2F5D50);
    const sage = Color(0xFF7D9B76);
    return _shell(
      paper: const Color(0xFFF3F6F1),
      painter: const _BotanicalFramePainter(color: leaf),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Column(
          children: [
            Text(
              copy.brand.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: sage,
                fontSize: 9,
                letterSpacing: 2.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: leaf,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            _copyBlock(ink: leaf, course: leaf, script: true),
            const Spacer(),
            _footer(ink: leaf, sealColor: sage),
          ],
        ),
      ),
    );
  }

  Widget _imperial() {
    const purple = Color(0xFF3C1361);
    const gold = Color(0xFFC6A15B);
    return _shell(
      paper: const Color(0xFFFBF7EF),
      painter: const _ImperialFramePainter(purple: purple, gold: gold),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Column(
          children: [
            Text(
              copy.brand.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              copy.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: purple,
                fontSize: 11,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 6),
            const _Ornament(color: gold, width: 80),
            const SizedBox(height: 4),
            _copyBlock(ink: purple, course: purple, script: true),
            const Spacer(),
            _footer(ink: purple, sealColor: gold),
          ],
        ),
      ),
    );
  }

  Widget _midnight() {
    const gold = Color(0xFFD4BE86);
    const cream = Color(0xFFF6EFE2);
    const ink = Color(0xFF07111F);
    return _shell(
      paper: ink,
      painter: const _LineFramePainter(color: gold, outer: 0.8, inner: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: Column(
          children: [
            Text(
              copy.brand.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 10,
                letterSpacing: 3.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              copy.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: cream,
                fontSize: 12,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 8),
            _copyBlock(ink: cream, course: gold, muted: gold),
            const Spacer(),
            _footer(ink: gold, muted: const Color(0xFFB7A88A)),
          ],
        ),
      ),
    );
  }

  Widget _deco() {
    const ink = Color(0xFF1A1A1A);
    const gold = Color(0xFFC6A15B);
    return _shell(
      paper: const Color(0xFFF7F3EA),
      painter: const _DecoFramePainter(color: gold),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 18, 26, 12),
        child: Column(
          children: [
            Text(
              copy.brand.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 9,
                letterSpacing: 3.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              copy.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 72,
              height: 2,
              color: gold,
            ),
            const SizedBox(height: 6),
            _copyBlock(ink: ink, course: ink),
            const Spacer(),
            _footer(ink: ink, sealColor: gold),
          ],
        ),
      ),
    );
  }

  Widget _ribbon() {
    const teal = Color(0xFF0F6E6E);
    return _shell(
      paper: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: teal,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              children: [
                Text(
                  copy.brand.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFD7EFEF),
                    fontSize: 8,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  copy.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Column(
                children: [
                  _copyBlock(ink: const Color(0xFF123C3C), course: teal),
                  const Spacer(),
                  _footer(ink: teal, seal: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _parchment() {
    const brown = Color(0xFF5C3A21);
    const wax = Color(0xFF9C2F2F);
    return _shell(
      paper: const Color(0xFFF3E6C8),
      painter: const _LineFramePainter(
        color: brown,
        outer: 0.9,
        inner: 0.35,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: Column(
          children: [
            Text(
              copy.brand.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: brown,
                fontSize: 10,
                letterSpacing: 2.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: brown,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            _copyBlock(ink: brown, course: brown, script: true),
            const Spacer(),
            _footer(ink: brown, sealColor: wax, filledSeal: true),
          ],
        ),
      ),
    );
  }

  Widget _horizon() {
    const panel = Color(0xFF1F4E79);
    const ink = Color(0xFF16324F);
    return _shell(
      paper: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 36,
            color: panel,
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                copy.brand.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 9,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: panel,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    certificate.studentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: 42,
                    height: 2,
                    color: panel,
                  ),
                  Text(
                    copy.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      color: const Color(0xFF4B5563),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    certificate.courseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      color: panel,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _footer(ink: panel, seal: false, alignStart: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyBlock({
    required Color ink,
    required Color course,
    Color? muted,
    bool script = false,
  }) {
    final quiet = muted ?? const Color(0xFF6B7280);
    return Column(
      children: [
        Text(
          copy.confers,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: quiet,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          certificate.studentName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: script
              ? GoogleFonts.greatVibes(
                  color: ink,
                  fontSize: 26,
                  height: 1.05,
                )
              : GoogleFonts.cinzel(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
        ),
        const SizedBox(height: 2),
        Text(
          copy.body,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorantGaramond(
            color: muted ?? const Color(0xFF374151),
            fontSize: 11,
          ),
        ),
        Text(
          certificate.courseName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorantGaramond(
            color: course,
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _footer({
    required Color ink,
    Color? muted,
    Color? sealColor,
    bool seal = true,
    bool filledSeal = false,
    bool alignStart = false,
  }) {
    final sign = _Sign(
      title: copy.issuedOn,
      subtitle: '${copy.folioLabel} ${certificate.folio}',
      color: ink,
      muted: muted,
    );
    final teacher = _Sign(
      title: teacherName,
      subtitle: copy.teacherLabel,
      color: ink,
      muted: muted,
      end: !alignStart,
    );
    if (!seal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: sign),
          Expanded(child: teacher),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: sign),
        _Seal(
          color: sealColor ?? ink,
          year: certificate.issuedAt.year,
          filled: filledSeal,
        ),
        Expanded(child: teacher),
      ],
    );
  }

  Widget _shell({
    required Color paper,
    CustomPainter? painter,
    required Widget child,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ColoredBox(
        color: paper,
        child: painter == null
            ? child
            : CustomPaint(painter: painter, child: child),
      ),
    );
  }
}

class _Watermark extends StatelessWidget {
  final String text;
  final Color color;

  const _Watermark({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.rotate(
          angle: -0.42,
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.cinzelDecorative(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.05),
              letterSpacing: 6,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  final Color color;
  final double width;

  const _Ornament({required this.color, this.width = 108});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: width / 2 - 10, height: 0.8, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 6, height: 6, color: color),
          ),
        ),
        Container(width: width / 2 - 10, height: 0.8, color: color),
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  final Color color;
  final int year;
  final bool filled;

  const _Seal({
    required this.color,
    required this.year,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = filled ? const Color(0xFFFFF6E8) : color;
    return CustomPaint(
      painter: _SealPainter(color: color, filled: filled),
      child: SizedBox(
        width: 58,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DOC',
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ink,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              '$year',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 9,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sign extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color? muted;
  final bool end;

  const _Sign({
    required this.title,
    required this.subtitle,
    required this.color,
    this.muted,
    this.end = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(width: 96, height: 1, color: color),
        const SizedBox(height: 1),
        Container(width: 96, height: 0.5, color: color.withValues(alpha: 0.4)),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: end ? TextAlign.right : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 9,
            color: muted ?? Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ClassicFramePainter extends CustomPainter {
  final Color gold;
  final Color navy;

  const _ClassicFramePainter({required this.gold, required this.navy});

  @override
  void paint(Canvas canvas, Size size) {
    _strokeRect(canvas, size, 4, 3.1, gold);
    _strokeRect(canvas, size, 8.5, 1.05, navy);
    _strokeRect(canvas, size, 11.5, 0.55, gold);

    final faint = Paint()
      ..color = gold.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    for (var i = 0; i < 5; i++) {
      final inset = 16.0 + i * 2.1;
      canvas.drawRRect(
        RRect.fromLTRBR(
          inset,
          inset,
          size.width - inset,
          size.height - inset,
          const Radius.circular(8),
        ),
        faint,
      );
    }

    const inset = 16.0;
    const len = 22.0;
    _cornerL(canvas, const Offset(inset, inset), 1, 1, len, gold);
    _cornerL(canvas, Offset(size.width - inset, inset), -1, 1, len, gold);
    _cornerL(canvas, Offset(inset, size.height - inset), 1, -1, len, gold);
    _cornerL(
      canvas,
      Offset(size.width - inset, size.height - inset),
      -1,
      -1,
      len,
      gold,
    );
    _rosette(canvas, Offset(size.width / 2, 11.5), gold);
    _rosette(canvas, Offset(size.width / 2, size.height - 11.5), gold);
  }

  @override
  bool shouldRepaint(covariant _ClassicFramePainter oldDelegate) {
    return oldDelegate.gold != gold || oldDelegate.navy != navy;
  }
}

class _ModernFramePainter extends CustomPainter {
  final Color primary;
  final Color gold;

  const _ModernFramePainter({required this.primary, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 10, size.height),
      Paint()..color = primary,
    );
    canvas.drawRect(
      Rect.fromLTWH(10, 0, 2.6, size.height),
      Paint()..color = gold,
    );
    canvas.drawRect(
      Rect.fromLTWH(12.6, 0, size.width - 12.6, 6),
      Paint()..color = const Color(0xFFDCE6F5),
    );

    final ring = Paint()
      ..color = primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.width - 36, size.height / 2),
        48.0 - i * 10,
        ring,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ModernFramePainter oldDelegate) {
    return oldDelegate.primary != primary;
  }
}

class _ElegantFramePainter extends CustomPainter {
  final Color color;

  const _ElegantFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _strokeRect(canvas, size, 6, 0.9, color);
    _strokeRect(canvas, size, 10, 0.45, color);
    _strokeRect(canvas, size, 13, 0.3, color.withValues(alpha: 0.45));

    const inset = 17.0;
    const len = 18.0;
    _cornerL(canvas, const Offset(inset, inset), 1, 1, len, color);
    _cornerL(canvas, Offset(size.width - inset, inset), -1, 1, len, color);
    _cornerL(canvas, Offset(inset, size.height - inset), 1, -1, len, color);
    _cornerL(
      canvas,
      Offset(size.width - inset, size.height - inset),
      -1,
      -1,
      len,
      color,
    );
  }

  @override
  bool shouldRepaint(covariant _ElegantFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _LineFramePainter extends CustomPainter {
  final Color color;
  final double outer;
  final double? inner;

  const _LineFramePainter({
    required this.color,
    required this.outer,
    this.inner,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _strokeRect(canvas, size, 7, outer, color);
    final innerWidth = inner;
    if (innerWidth != null) {
      _strokeRect(
        canvas,
        size,
        11,
        innerWidth,
        color.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineFramePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.outer != outer ||
        oldDelegate.inner != inner;
  }
}

class _BotanicalFramePainter extends CustomPainter {
  final Color color;

  const _BotanicalFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _strokeRect(canvas, size, 7, 1, color);
    _strokeRect(canvas, size, 11, 0.4, color.withValues(alpha: 0.4));
    final stem = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    void sprig(Offset origin, double sx, double sy) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(
          origin.dx + 10 * sx,
          origin.dy + 1 * sy,
          origin.dx + 12 * sx,
          origin.dy + 8 * sy,
        )
        ..quadraticBezierTo(
          origin.dx + 4 * sx,
          origin.dy + 6 * sy,
          origin.dx,
          origin.dy,
        );
      canvas.drawPath(path, stem);
      canvas.drawLine(
        origin,
        origin + Offset(11 * sx, 7 * sy),
        stem,
      );
    }

    sprig(const Offset(12, 12), 1, 1);
    sprig(Offset(size.width - 12, 12), -1, 1);
    sprig(Offset(12, size.height - 12), 1, -1);
    sprig(Offset(size.width - 12, size.height - 12), -1, -1);
  }

  @override
  bool shouldRepaint(covariant _BotanicalFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ImperialFramePainter extends CustomPainter {
  final Color purple;
  final Color gold;

  const _ImperialFramePainter({required this.purple, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _strokeRect(canvas, size, 8, 1.1, purple);
    _strokeRect(canvas, size, 12, 0.45, gold);
    _rosette(canvas, Offset(size.width / 2, 8), gold);
    _rosette(canvas, Offset(size.width / 2, size.height - 8), gold);
  }

  @override
  bool shouldRepaint(covariant _ImperialFramePainter oldDelegate) {
    return oldDelegate.purple != purple || oldDelegate.gold != gold;
  }
}

class _DecoFramePainter extends CustomPainter {
  final Color color;

  const _DecoFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeJoin = StrokeJoin.miter;
    void steps(Offset origin, double sx, double sy) {
      for (var i = 0; i < 3; i++) {
        final length = 6.0 + i * 4;
        final path = Path()
          ..moveTo(origin.dx + sx * length, origin.dy)
          ..lineTo(origin.dx, origin.dy)
          ..lineTo(origin.dx, origin.dy + sy * length);
        canvas.drawPath(path, paint);
      }
    }

    steps(const Offset(10, 10), 1, 1);
    steps(Offset(size.width - 10, 10), -1, 1);
    steps(Offset(10, size.height - 10), 1, -1);
    steps(Offset(size.width - 10, size.height - 10), -1, -1);
  }

  @override
  bool shouldRepaint(covariant _DecoFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SealPainter extends CustomPainter {
  final Color color;
  final bool filled;

  const _SealPainter({required this.color, this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2.5;
    if (filled) {
      canvas.drawCircle(center, r, Paint()..color = color);
      canvas.drawCircle(
        center,
        r - 3.4,
        Paint()
          ..color = const Color(0xFFFFF6E8).withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
      return;
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center, r - 4.5, paint..strokeWidth = 0.55);

    final tick = Paint()
      ..color = color
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi * 2 / 24;
      canvas.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * (r - 1),
        center + Offset(math.cos(a), math.sin(a)) * (r + 1.2),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}

void _strokeRect(
  Canvas canvas,
  Size size,
  double inset,
  double width,
  Color color,
) {
  canvas.drawRect(
    Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset),
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width,
  );
}

void _cornerL(
  Canvas canvas,
  Offset origin,
  double dx,
  double dy,
  double len,
  Color color,
) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.25
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter;
  final path = Path()
    ..moveTo(origin.dx, origin.dy + dy * len)
    ..lineTo(origin.dx, origin.dy)
    ..lineTo(origin.dx + dx * len, origin.dy);
  canvas.drawPath(path, paint);
  final inner = Path()
    ..moveTo(origin.dx + dx * 4, origin.dy + dy * (len * 0.58))
    ..lineTo(origin.dx + dx * 4, origin.dy + dy * 4)
    ..lineTo(origin.dx + dx * (len * 0.58), origin.dy + dy * 4);
  canvas.drawPath(inner, paint..strokeWidth = 0.5);
}

void _rosette(Canvas canvas, Offset center, Color color) {
  const s = 3.0;
  final path = Path()
    ..moveTo(center.dx, center.dy - s)
    ..lineTo(center.dx + s, center.dy)
    ..lineTo(center.dx, center.dy + s)
    ..lineTo(center.dx - s, center.dy)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
}

class CertificateStyleThumb extends StatelessWidget {
  final CertificateStyle style;
  final Color accent;

  const CertificateStyleThumb({
    super.key,
    required this.style,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      CertificateStyle.ribbon => const _RibbonThumb(),
      CertificateStyle.horizon => const _HorizonThumb(),
      CertificateStyle.midnight => const _AbstractThumb(
          paper: Color(0xFF07111F),
          bar: Color(0xFFD4BE86),
          title: Color(0xFFF6EFE2),
          painter: _LineFramePainter(color: Color(0xFFD4BE86), outer: 0.8),
        ),
      CertificateStyle.academic => const _AbstractThumb(
          paper: Color(0xFFF4F1EA),
          bar: Color(0xFF8C2F39),
          title: Color(0xFF1B3A4B),
          painter: _LineFramePainter(color: Color(0xFF1B3A4B), outer: 0.9),
          header: Color(0xFF1B3A4B),
        ),
      CertificateStyle.minimal => const _AbstractThumb(
          paper: Colors.white,
          bar: Color(0xFF1F2933),
          title: Color(0xFF1F2933),
          painter: _LineFramePainter(color: Color(0xFFD6D3D1), outer: 0.7),
        ),
      CertificateStyle.botanical => const _AbstractThumb(
          paper: Color(0xFFF3F6F1),
          bar: Color(0xFF7D9B76),
          title: Color(0xFF2F5D50),
          painter: _BotanicalFramePainter(color: Color(0xFF2F5D50)),
        ),
      CertificateStyle.imperial => const _AbstractThumb(
          paper: Color(0xFFFBF7EF),
          bar: Color(0xFFC6A15B),
          title: Color(0xFF3C1361),
          painter: _ImperialFramePainter(
            purple: Color(0xFF3C1361),
            gold: Color(0xFFC6A15B),
          ),
        ),
      CertificateStyle.deco => const _AbstractThumb(
          paper: Color(0xFFF7F3EA),
          bar: Color(0xFFC6A15B),
          title: Color(0xFF1A1A1A),
          painter: _DecoFramePainter(color: Color(0xFFC6A15B)),
        ),
      CertificateStyle.parchment => const _AbstractThumb(
          paper: Color(0xFFF3E6C8),
          bar: Color(0xFF9C2F2F),
          title: Color(0xFF5C3A21),
          painter: _LineFramePainter(color: Color(0xFF5C3A21), outer: 0.9),
        ),
      CertificateStyle.classic ||
      CertificateStyle.modern ||
      CertificateStyle.elegant =>
        _legacyThumb(),
    };
  }

  Widget _legacyThumb() {
    final (Color paper, CustomPainter painter, Color bar, Color title) =
        switch (style) {
      CertificateStyle.classic => (
          const Color(0xFFFBF6EC),
          _ClassicFramePainter(gold: const Color(0xFFC4A35A), navy: accent),
          const Color(0xFFC4A35A),
          accent,
        ),
      CertificateStyle.modern => (
          Colors.white,
          _ModernFramePainter(primary: accent, gold: const Color(0xFFC4A35A)),
          accent,
          const Color(0xFF111827),
        ),
      CertificateStyle.elegant => (
          const Color(0xFFF7F0E4),
          const _ElegantFramePainter(color: Color(0xFF6B2D5B)),
          const Color(0xFF6B2D5B),
          const Color(0xFF6B2D5B),
        ),
      _ => (
          Colors.white,
          const _LineFramePainter(color: Color(0xFFD6D3D1), outer: 0.7),
          accent,
          accent,
        ),
    };

    return ColoredBox(
      color: paper,
      child: CustomPaint(
        painter: painter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 28, height: 2, color: bar),
              const SizedBox(height: 7),
              Container(
                width: 46,
                height: 5,
                color: title.withValues(alpha: 0.28),
              ),
              const SizedBox(height: 4),
              Container(
                width: 34,
                height: 3,
                color: bar.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AbstractThumb extends StatelessWidget {
  final Color paper;
  final Color bar;
  final Color title;
  final CustomPainter painter;
  final Color? header;

  const _AbstractThumb({
    required this.paper,
    required this.bar,
    required this.title,
    required this.painter,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: paper,
      child: CustomPaint(
        painter: painter,
        child: Column(
          children: [
            if (header != null) Container(height: 14, color: header),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 28, height: 2, color: bar),
                  const SizedBox(height: 7),
                  Container(
                    width: 46,
                    height: 5,
                    color: title.withValues(alpha: 0.28),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 34,
                    height: 3,
                    color: bar.withValues(alpha: 0.55),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibbonThumb extends StatelessWidget {
  const _RibbonThumb();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          ColoredBox(
            color: Color(0xFF0F6E6E),
            child: SizedBox(height: 22, width: double.infinity),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 40,
                height: 2,
                child: ColoredBox(color: Color(0xFF0F6E6E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizonThumb extends StatelessWidget {
  const _HorizonThumb();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: Color(0xFF1F4E79),
            child: SizedBox(width: 16),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 36,
                height: 2,
                child: ColoredBox(color: Color(0xFF1F4E79)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
