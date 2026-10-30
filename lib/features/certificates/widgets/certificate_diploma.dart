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

  const _Seal({required this.color, required this.year});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SealPainter(color: color),
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
                color: color,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              '$year',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 9,
                color: color,
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
  final bool end;

  const _Sign({
    required this.title,
    required this.subtitle,
    required this.color,
    this.end = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
            color: Colors.grey.shade600,
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

class _SealPainter extends CustomPainter {
  final Color color;

  const _SealPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2.5;
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
    return oldDelegate.color != color;
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
