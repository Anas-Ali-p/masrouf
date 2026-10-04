import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/report_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class _PdfFonts {
  _PdfFonts._(this.regular, this.bold);
  final pw.Font regular;
  final pw.Font bold;

  static _PdfFonts? _cache;
  static Future<_PdfFonts> load() async {
    if (_cache != null) return _cache!;
    _cache = _PdfFonts._(
      pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf')),
      pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Bold.ttf')),
    );
    return _cache!;
  }
}

Future<void> exportReport({
  required ReportData data,
  required String periodLabel,
  String currency = 'SAR',
}) async {
  final bytes = await buildReportPdf(
    data: data,
    periodLabel: periodLabel,
    currency: currency,
  );

  try {
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    return;
  } catch (_) {}

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/report.pdf');
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')]);
}

Future<Uint8List> buildReportPdf({
  required ReportData data,
  required String periodLabel,
  String currency = 'SAR',
}) async {
  final fonts = await _PdfFonts.load();
  final doc = pw.Document();
  final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold);
  final fmt = NumberFormat('#,##0.00', 'en');
  final dateFmt = DateFormat('yyyy/MM/dd');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: theme,
      margin: const pw.EdgeInsets.all(28),
      build: (ctx) => [
        pw.Text(
          'تقرير مالي',
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '$periodLabel  ·  '
          '${dateFmt.format(data.range.start)} — ${dateFmt.format(data.range.end)}',
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 11,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Divider(color: PdfColors.grey400),

        // Summary
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _box(
              fonts,
              'الدخل',
              '${fmt.format(data.income)} $currency',
              PdfColors.green700,
            ),
            pw.SizedBox(width: 8),
            _box(
              fonts,
              'المصروف',
              '${fmt.format(data.expense)} $currency',
              PdfColors.red700,
            ),
            pw.SizedBox(width: 8),
            _box(
              fonts,
              'الصافي',
              '${fmt.format(data.net)} $currency',
              data.net >= 0 ? PdfColors.green700 : PdfColors.red700,
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // By category
        pw.Text(
          'التوزيع حسب التصنيف',
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const ['التصنيف', 'المبلغ', 'النسبة'],
          data: data.categories.map((c) {
            final pct = data.expense == 0
                ? 0.0
                : (c.amount / data.expense) * 100;
            return [
              c.category,
              fmt.format(c.amount),
              '${pct.toStringAsFixed(1)}%',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            font: fonts.bold,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 11,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey800,
          ),
          cellStyle: pw.TextStyle(font: fonts.regular, fontSize: 10),
          cellAlignment: pw.Alignment.centerRight,
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        ),

        pw.SizedBox(height: 18),
        pw.Text(
          'الاتجاه الشهري',
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const ['الشهر', 'الدخل', 'المصروف'],
          data: data.months.map((m) {
            return [
              DateFormat('yyyy/MM').format(m.month),
              fmt.format(m.income),
              fmt.format(m.expense),
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            font: fonts.bold,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 11,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey800,
          ),
          cellStyle: pw.TextStyle(font: fonts.regular, fontSize: 10),
          cellAlignment: pw.Alignment.centerRight,
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        ),

        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 4),
        pw.Text(
          'تم إنشاء هذا التقرير تلقائياً من التطبيق.',
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _box(_PdfFonts fonts, String label, String value, PdfColor color) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
