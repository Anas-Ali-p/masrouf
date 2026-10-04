import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────
//  Font cache — load once per app session
// ─────────────────────────────────────────────────────────

class _PdfFonts {
  _PdfFonts._(this.regular, this.semiBold, this.bold);

  final pw.Font regular;
  final pw.Font semiBold;
  final pw.Font bold;

  static _PdfFonts? _cache;

  static Future<_PdfFonts> load() async {
    if (_cache != null) return _cache!;
    final r = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final sb = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-SemiBold.ttf'),
    );
    final b = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    _cache = _PdfFonts._(r, sb, b);
    return _cache!;
  }
}

// ─────────────────────────────────────────────────────────
//  Public API
// ─────────────────────────────────────────────────────────

Future<void> exportAccountStatement({
  required Account account,
  required List<Transaction> transactions,
}) async {
  final bytes = await buildAccountStatementPdf(
    account: account,
    transactions: transactions,
  );

  // 1) Native share sheet (Android / iOS / macOS)
  try {
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'account_statement_${account.id}.pdf',
    );
    return;
  } catch (_) {
    // Fall through
  }

  // 2) Fallback — write to temp + share_plus
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/account_statement_${account.id}.pdf');
  await file.writeAsBytes(bytes, flush: true);

  await Share.shareXFiles([
    XFile(file.path, mimeType: 'application/pdf'),
  ], subject: 'كشف حساب - ${account.name}');
}

Future<Uint8List> buildAccountStatementPdf({
  required Account account,
  required List<Transaction> transactions,
}) async {
  final fonts = await _PdfFonts.load();
  final doc = pw.Document();

  // Base theme: every widget inherits Cairo Regular by default.
  final theme = pw.ThemeData.withFont(
    base: fonts.regular,
    bold: fonts.bold,
    italic: fonts.regular,
    boldItalic: fonts.bold,
  );

  final fmt = NumberFormat('#,##0.00', 'en');
  final dateFmt = DateFormat('yyyy/MM/dd');

  final totalIncome = transactions
      .where((t) => t.isIncome)
      .fold<double>(0, (s, t) => s + t.amount);
  final totalExpense = transactions
      .where((t) => !t.isIncome)
      .fold<double>(0, (s, t) => s + t.amount);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: theme,
      margin: const pw.EdgeInsets.all(28),
      build: (ctx) => [
        // ── Header ─────────────────────────────────────
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'كشف حساب',
                  style: pw.TextStyle(
                    font: fonts.bold,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  account.name,
                  style: pw.TextStyle(font: fonts.regular, fontSize: 14),
                ),
                if (account.accountNumber != null)
                  pw.Text(
                    account.accountNumber!,
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'تاريخ الإصدار',
                  style: pw.TextStyle(
                    font: fonts.regular,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  dateFmt.format(DateTime.now()),
                  style: pw.TextStyle(font: fonts.regular, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey400),

        // ── Summary row ────────────────────────────────
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _summaryBox(
              fonts,
              'الرصيد الحالي',
              '${fmt.format(account.balance)} ${account.currency}',
              PdfColors.blue800,
            ),
            pw.SizedBox(width: 8),
            _summaryBox(
              fonts,
              'إجمالي الدخل',
              '${fmt.format(totalIncome)} ${account.currency}',
              PdfColors.green700,
            ),
            pw.SizedBox(width: 8),
            _summaryBox(
              fonts,
              'إجمالي المصروف',
              '${fmt.format(totalExpense)} ${account.currency}',
              PdfColors.red700,
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // ── Transactions table ─────────────────────────
        pw.Text(
          'العمليات',
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),

        pw.TableHelper.fromTextArray(
          headers: const ['التاريخ', 'الوصف', 'التصنيف', 'المبلغ'],
          data: transactions.map((t) {
            final prefix = t.isIncome ? '+' : '-';
            return [
              dateFmt.format(t.date),
              t.title,
              t.category,
              '$prefix${fmt.format(t.amount)}',
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
          'تم إنشاء هذا الكشف تلقائياً من التطبيق.',
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

// ─────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────

pw.Widget _summaryBox(
  _PdfFonts fonts,
  String label,
  String value,
  PdfColor color,
) {
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
