import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item.dart';
import '../models/category.dart';

class PdfService {
  static Future<void> exportItems(List<CollectionItem> items) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    // Kategoriyalar bo'yicha guruhlash
    final grouped = <String, List<CollectionItem>>{};
    for (final cat in categories) {
      final catItems = items.where((i) => i.category == cat.id).toList();
      if (catItems.isNotEmpty) {
        grouped[cat.id] = catItems;
      }
    }

    final totalValue = items.fold(0.0, (s, i) => s + i.price);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'KOLLEKSIYA RO\'YXATI',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('BA7517'),
                  ),
                ),
                pw.Text(
                  dateStr,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromHex('888680'),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColor.fromHex('BA7517')),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Jami: ${items.length} ta element | ${_formatPrice(totalValue)}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('854F0B'),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('888680'),
              ),
            ),
          ],
        ),
        build: (ctx) => [
          // Statistika xulosa
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('FFF8F0'),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromHex('FAEEDA')),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _statBlock('Jami', '${items.length} ta'),
                _statBlock('Kategoriyalar', '${grouped.length} ta'),
                _statBlock('Umumiy qiymat', _formatPrice(totalValue)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Kategoriyalar bo'yicha
          ...grouped.entries.map((entry) {
            final cat = getCategoryById(entry.key);
            final catItems = entry.value;
            final catTotal =
                catItems.fold(0.0, (s, i) => s + i.price);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex(
                        cat.color.value.toRadixString(16).padLeft(8, '0').substring(2)),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${cat.name.toUpperCase()} (${catItems.length} ta)',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        _formatPrice(catTotal),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('EEE8E0'),
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(4),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F5F0E8'),
                      ),
                      children: [
                        _cell('#', bold: true),
                        _cell('Nomi', bold: true),
                        _cell('Tavsif', bold: true),
                        _cell("Qiymati", bold: true, right: true),
                      ],
                    ),
                    ...catItems.asMap().entries.map((e) {
                      return pw.TableRow(
                        children: [
                          _cell('${e.key + 1}'),
                          _cell(e.value.name),
                          _cell(e.value.description),
                          _cell(_formatPrice(e.value.price),
                              right: true, color: PdfColor.fromHex('854F0B')),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'kolleksiya_$dateStr.pdf',
    );
  }

  static pw.Widget _statBlock(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
                color: PdfColor.fromHex('BA7517'))),
        pw.SizedBox(height: 2),
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 10, color: PdfColor.fromHex('888680'))),
      ],
    );
  }

  static pw.Widget _cell(String text,
      {bool bold = false, bool right = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  static String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
      count++;
    }
    return "${buffer.toString().split('').reversed.join()} so'm";
  }
}
