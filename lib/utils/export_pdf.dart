import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../data/models/transaction_model.dart';

class PdfExporter {
  static Future<File> exportTransactions(
      List<TransactionModel> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'SpendWise Transactions',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Table.fromTextArray(
            headers: [
              'Date',
              'Type',
              'Category',
              'Amount',
              'Note',
            ],
            data: transactions.map((t) {
              return [
                _formatDate(t.date),
                t.type.toUpperCase(),
                t.category,
                t.amount.toStringAsFixed(2),
                t.note ?? '',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/spendwise_transactions_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
