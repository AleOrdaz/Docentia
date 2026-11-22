import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../courses/models/course_model.dart';
import '../logic/report_builders.dart';

class ReportExcelService {
  Uint8List buildStudentMonthWorkbook({
    required String courseName,
    required String periodLabel,
    required BillingFrequency billingFrequency,
    required List<StudentMonthExportRow> rows,
    required AppLocalizations l10n,
  }) {
    final billingLabel = _billingLabel(billingFrequency, l10n);
    final table = <List<Object>>[
      [l10n.reportCourse, courseName],
      [l10n.reportExcelBillingType, billingLabel],
      [l10n.courseReportTitle, periodLabel],
      const [''],
      [
        l10n.reportStudent,
        l10n.reportExcelAttendances,
        l10n.reportExcelBillingType,
        l10n.reportExcelDailyRate,
        l10n.reportExcelTotal,
        l10n.reportExcelHours,
      ],
      for (final row in rows)
        [
          row.name,
          row.attendances,
          billingLabel,
          _round2(row.dailyRate),
          _round2(row.total),
          _round2(row.hours),
        ],
    ];

    return _xlsx(
      sheetName: 'Alumnos',
      rows: table,
      columnWidths: const [28, 22, 20, 16, 14, 18],
    );
  }

  Future<void> share({
    required Uint8List bytes,
    required String filename,
    required AppLocalizations l10n,
    required void Function(String message) onMessage,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    try {
      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            name: filename,
          ),
        ],
        subject: filename,
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      );
      return;
    } catch (_) {}

    try {
      final shared = await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
        subject: filename,
      );
      if (shared) return;
    } catch (_) {}

    final documents = await getApplicationDocumentsDirectory();
    final saved = File('${documents.path}/$filename');
    await saved.writeAsBytes(bytes, flush: true);
    onMessage(l10n.reportSavedInDocuments(filename));
  }

  String _billingLabel(BillingFrequency frequency, AppLocalizations l10n) {
    switch (frequency) {
      case BillingFrequency.perClass:
        return l10n.reportBillingPerClass;
      case BillingFrequency.weekly:
        return l10n.reportBillingWeekly;
      case BillingFrequency.biweekly:
        return l10n.reportBillingBiweekly;
      case BillingFrequency.monthly:
        return l10n.reportBillingMonthly;
    }
  }

  double _round2(double value) => double.parse(value.toStringAsFixed(2));
}

Uint8List _xlsx({
  required String sheetName,
  required List<List<Object>> rows,
  required List<double> columnWidths,
}) {
  final sheet = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..writeln(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    );
  if (columnWidths.isNotEmpty) {
    sheet.writeln('<cols>');
    for (var i = 0; i < columnWidths.length; i++) {
      final width = columnWidths[i];
      final index = i + 1;
      sheet.writeln(
        '<col min="$index" max="$index" width="$width" customWidth="1"/>',
      );
    }
    sheet.writeln('</cols>');
  }
  sheet.writeln('<sheetData>');
  for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    sheet.write('<row r="$rowNumber">');
    final cells = rows[rowIndex];
    for (var column = 0; column < cells.length; column++) {
      final ref = '${_columnName(column)}$rowNumber';
      final value = cells[column];
      if (value is num) {
        sheet.write('<c r="$ref"><v>$value</v></c>');
      } else {
        sheet.write(
          '<c r="$ref" t="inlineStr"><is><t>${_xml(value.toString())}</t></is></c>',
        );
      }
    }
    sheet.writeln('</row>');
  }
  sheet
    ..writeln('</sheetData>')
    ..write('</worksheet>');

  final archive = Archive()
    ..addFile(_file('[Content_Types].xml', _contentTypes))
    ..addFile(_file('_rels/.rels', _rootRels))
    ..addFile(_file('xl/workbook.xml', _workbook(sheetName)))
    ..addFile(_file('xl/_rels/workbook.xml.rels', _workbookRels))
    ..addFile(_file('xl/worksheets/sheet1.xml', sheet.toString()));

  final encoded = ZipEncoder().encode(archive);
  return Uint8List.fromList(encoded);
}

ArchiveFile _file(String name, String contents) {
  final bytes = utf8.encode(contents);
  return ArchiveFile(name, bytes.length, bytes);
}

String _columnName(int index) {
  var value = index;
  final letters = StringBuffer();
  do {
    letters.writeCharCode(65 + (value % 26));
    value = (value ~/ 26) - 1;
  } while (value >= 0);
  return letters.toString().split('').reversed.join();
}

String _xml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

String _workbook(String sheetName) {
  return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="${_xml(sheetName)}" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>
''';
}

const _contentTypes = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
</Types>
''';

const _rootRels = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>
''';

const _workbookRels = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
</Relationships>
''';
