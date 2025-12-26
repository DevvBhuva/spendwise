import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

class CsvExporter {
  static Future<void> exportTransactions(
    List<TransactionModel> transactions,
  ) async {
    if (transactions.isEmpty) return;

    // CSV header
    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Type,Category,Payment Way,Amount,Note',
    );

    // Rows
    for (final t in transactions) {
      buffer.writeln(
        '${t.date.toIso8601String()},'
        '${t.type},'
        '${t.category},'
        '${t.paymentWay},'
        '${t.amount},'
        '${t.note}',
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/spendwise_transactions.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'SpendWise Transactions',
    );
  }
}
