import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../finance/widgets/finance_ui.dart';
import '../../payments/models/payment_model.dart';
import '../logic/report_builders.dart';

class ReportPdfService {
  Future<Uint8List> buildCoursePdf({
    required CourseReportData data,
    required AppLocalizations l10n,
    required String periodLabel,
    required String teacherName,
    required String generatedOn,
  }) async {
    return _build(
      title: l10n.courseReportTitle,
      subtitle: '${data.courseName} · $periodLabel',
      teacherName: teacherName,
      generatedOn: generatedOn,
      l10n: l10n,
      children: [
        _kvGrid([
          (l10n.reportSchedule, data.schedule),
          (l10n.reportMonthlyCost, formatCurrency(data.cost)),
          (l10n.studentListTitle, '${data.studentCount}'),
          (l10n.classesLabel, '${data.sessionCount}'),
        ]),
        pw.SizedBox(height: 14),
        _sectionTitle(l10n.reportAttendance),
        _kvGrid([
          (l10n.attendancesLabel, '${data.presents}'),
          (l10n.lateStatus, '${data.lates}'),
          (l10n.absencesLabel, '${data.absences}'),
        ]),
        pw.SizedBox(height: 14),
        _sectionTitle(l10n.financeReports),
        _kvGrid([
          (l10n.financeCollected, formatCurrency(data.collected)),
          (l10n.financeToCollect, formatCurrency(data.toCollect)),
          (l10n.financeOverdue, formatCurrency(data.overdue)),
          (l10n.financeExpenses, formatCurrency(data.expenses)),
          (l10n.financeRealProfit, formatCurrency(data.profit)),
        ]),
        pw.SizedBox(height: 16),
        _sectionTitle(l10n.studentListTitle),
        pw.SizedBox(height: 8),
        if (data.students.isEmpty)
          pw.Text(l10n.noStudentsInCourse, style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey600))
        else
          _table(
            headers: [
              l10n.reportStudent,
              l10n.attendancesLabel,
              l10n.lateStatus,
              l10n.absencesLabel,
              l10n.reportPayment,
            ],
            rows: [
              for (final row in data.students)
                [
                  row.name,
                  '${row.presents}',
                  '${row.lates}',
                  '${row.absences}',
                  _paymentLabel(l10n, row.paymentStatus),
                ],
            ],
            aligns: const [
              pw.Alignment.centerLeft,
              pw.Alignment.center,
              pw.Alignment.center,
              pw.Alignment.center,
              pw.Alignment.centerRight,
            ],
          ),
      ],
    );
  }

  Future<Uint8List> buildFinancePdf({
    required FinanceReportData data,
    required AppLocalizations l10n,
    required String periodLabel,
    required String teacherName,
    required String generatedOn,
  }) async {
    return _build(
      title: l10n.financeReportTitle,
      subtitle: periodLabel,
      teacherName: teacherName,
      generatedOn: generatedOn,
      l10n: l10n,
      children: [
        _kvGrid([
          (l10n.financeCollected, formatCurrency(data.totals.collected)),
          (l10n.financeToCollect, formatCurrency(data.totals.toCollect)),
          (l10n.financeOverdue, formatCurrency(data.totals.overdue)),
          (l10n.financeUpcoming, formatCurrency(data.totals.upcoming)),
          (l10n.financeExpenses, formatCurrency(data.expenses)),
          (l10n.financeRealProfit, formatCurrency(data.profit)),
        ]),
        pw.SizedBox(height: 16),
        _sectionTitle(l10n.financeByCourse),
        pw.SizedBox(height: 8),
        if (data.byCourse.isEmpty)
          pw.Text(l10n.financeNoCourseIncome, style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey600))
        else
          _table(
            headers: [l10n.reportCourse, l10n.financeCollected],
            rows: [
              for (final row in data.byCourse) [row.courseName, formatCurrency(row.collected)],
            ],
            aligns: const [pw.Alignment.centerLeft, pw.Alignment.centerRight],
          ),
        pw.SizedBox(height: 16),
        _sectionTitle(l10n.reportPendingPayments),
        pw.SizedBox(height: 8),
        if (data.unpaid.isEmpty)
          pw.Text(l10n.financeNoUnpaid, style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey600))
        else
          _table(
            headers: [l10n.reportStudent, l10n.reportCourse, l10n.reportAmount, l10n.reportPayment],
            rows: [
              for (final row in data.unpaid)
                [
                  row.studentName,
                  row.courseName,
                  formatCurrency(row.amount),
                  financeStatusLabel(l10n, row.status),
                ],
            ],
            aligns: const [
              pw.Alignment.centerLeft,
              pw.Alignment.centerLeft,
              pw.Alignment.centerRight,
              pw.Alignment.centerRight,
            ],
          ),
      ],
    );
  }

  Future<void> share({
    required Uint8List bytes,
    required String filename,
    required AppLocalizations l10n,
    required void Function(String message) onMessage,
  }) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (_) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      onMessage(l10n.certificateSaved);
    }
  }

  Future<Uint8List> _build({
    required String title,
    required String subtitle,
    required String teacherName,
    required String generatedOn,
    required AppLocalizations l10n,
    required List<pw.Widget> children,
  }) async {
    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final base = await PdfGoogleFonts.nunitoRegular();
    final bold = await PdfGoogleFonts.nunitoBold();
    const navy = PdfColor.fromInt(0xFF00236F);
    const muted = PdfColor.fromInt(0xFF64748B);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: base, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null) ...[
                  pw.Image(logo, width: 28, height: 28),
                  pw.SizedBox(width: 8),
                ],
                pw.Text(
                  l10n.appName,
                  style: pw.TextStyle(font: bold, fontSize: 12, color: navy),
                ),
                pw.Spacer(),
                pw.Text(
                  generatedOn,
                  style: const pw.TextStyle(fontSize: 9, color: muted),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 18, color: navy)),
            pw.SizedBox(height: 2),
            pw.Text(subtitle, style: const pw.TextStyle(fontSize: 11, color: muted)),
            pw.Text(
              '${l10n.certificateTeacherSign}: $teacherName',
              style: const pw.TextStyle(fontSize: 10, color: muted),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: const PdfColor.fromInt(0xFFD7DEE8), thickness: 0.8),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: muted),
          ),
        ),
        build: (context) => children,
      ),
    );

    return doc.save();
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(0xFF00236F),
      ),
    );
  }

  pw.Widget _kvGrid(List<(String, String)> items) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final item in items)
          pw.Container(
            width: 155,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF4F7FB),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.$1, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B))),
                pw.SizedBox(height: 2),
                pw.Text(
                  item.$2,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1B2A4A)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required List<pw.Alignment> aligns,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF00236F)),
      cellStyle: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF1B2A4A)),
      cellAlignments: {
        for (var i = 0; i < aligns.length; i++) i: aligns[i],
      },
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8FAFC)),
      border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.4),
    );
  }

  String _paymentLabel(AppLocalizations l10n, PaymentStatus? status) {
    if (status == null) return l10n.noFeeStatus;
    if (status == PaymentStatus.paid) return l10n.paymentUpToDate;
    return financeStatusLabel(l10n, status);
  }
}
