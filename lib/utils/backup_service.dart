import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data/repositories/transaction_repository.dart';
import '../data/models/transaction_model.dart';

class BackupService {
  BackupService._();

  // ─────────────────────────────────────────────
  // GOOGLE SIGN-IN & DRIVE
  // ─────────────────────────────────────────────

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  static GoogleSignInAccount? _account;
  static drive.DriveApi? _driveApi;

  static Future<String?> signIn() async {
    _account = await _googleSignIn.signIn();
    if (_account == null) return null;

    final headers = await _account!.authHeaders;
    _driveApi = drive.DriveApi(_GoogleAuthClient(headers));
    return _account!.email;
  }

  static Future<String> getOrCreateFolder() async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    final query =
        "mimeType='application/vnd.google-apps.folder' and name='SpendWise' and trashed=false";

    final result = await _driveApi!.files.list(q: query);

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder = drive.File()
      ..name = 'SpendWise'
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await _driveApi!.files.create(folder);
    return created.id!;
  }

  // ─────────────────────────────────────────────
  // JSON BACKUP
  // ─────────────────────────────────────────────

  static Future<String> generateJsonBackup() async {
    final repo = TransactionRepository();
    final transactions = await repo.getAllTransactions();

    print('🧾 BACKUP — total transactions: ${transactions.length}');

    return jsonEncode({
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'transactionCount': transactions.length,
      'transactions': transactions.map(_txToJson).toList(),
    });
  }

  static Map<String, dynamic> _txToJson(TransactionModel t) {
    return {
      'amount': t.amount,
      'type': t.type,
      'category': t.category,
      'note': t.note,
      'paymentWay': t.paymentWay,
      'date': t.date.toIso8601String(),
    };
  }

  // ─────────────────────────────────────────────
  // CREATE .MMBAK (ZIP)
  // ─────────────────────────────────────────────

  static Future<File> createCompressedBackup({
    required String jsonData,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/backup');
    backupDir.createSync(recursive: true);

    final dbFile = File('${dir.path}/spendwise.db');

    final jsonFile = File('${backupDir.path}/backup.json');
    await jsonFile.writeAsString(jsonData);

    final name =
        'spendwise_backup_${DateTime.now().millisecondsSinceEpoch}.mmbak';
    final path = '${backupDir.path}/$name';

    final encoder = ZipFileEncoder();
    encoder.create(path);

    if (dbFile.existsSync()) {
      encoder.addFile(dbFile);
    }
    encoder.addFile(jsonFile);

    encoder.close();
    return File(path);
  }

  // ─────────────────────────────────────────────
  // UPLOAD TO DRIVE
  // ─────────────────────────────────────────────

  static Future<void> uploadToDrive({
    required File file,
    required String folderId,
  }) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    await _driveApi!.files.create(
      drive.File()
        ..name = file.uri.pathSegments.last
        ..parents = [folderId],
      uploadMedia: drive.Media(
        file.openRead(),
        file.lengthSync(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RESTORE FROM .MMBAK
  // ─────────────────────────────────────────────

  static Future<int> restoreFromBackup(File mmbakFile) async {
    final repo = TransactionRepository();

    final bytes = await mmbakFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    late Map<String, dynamic> jsonData;

    for (final f in archive) {
      if (f.isFile && f.name == 'backup.json') {
        jsonData =
            jsonDecode(utf8.decode(f.content as List<int>));
      }
    }

    final List list = jsonData['transactions'];

    await repo.clearAllTransactions();

    for (final t in list) {
      await repo.insertTransaction(
        TransactionModel(
          amount: (t['amount'] as num).toDouble(),
          type: t['type'],
          category: t['category'],
          note: t['note'],
          paymentWay: t['paymentWay'],
          date: DateTime.parse(t['date']),
        ),
      );
    }

    return list.length;
  }

  // ─────────────────────────────────────────────
  // AUTO BACKUP (STRING BASED – SAFE)
  // ─────────────────────────────────────────────

  static Future<void> autoBackupIfNeeded() async {
    if (_driveApi == null) return;

    final prefs = await SharedPreferences.getInstance();
    final frequency =
        prefs.getString('backup_frequency') ?? 'manual';

    if (frequency == 'manual') return;

    final lastBackup =
        prefs.getInt('last_backup_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    Duration gap;
    switch (frequency) {
      case 'daily':
        gap = const Duration(days: 1);
        break;
      case 'weekly':
        gap = const Duration(days: 7);
        break;
      case 'monthly':
        gap = const Duration(days: 30);
        break;
      default:
        return;
    }

    if (now - lastBackup < gap.inMilliseconds) return;

    final json = await BackupService.generateJsonBackup();
    final file =
        await BackupService.createCompressedBackup(jsonData: json);
    final folderId = await BackupService.getOrCreateFolder();

    await BackupService.uploadToDrive(
      file: file,
      folderId: folderId,
    );

    await prefs.setInt('last_backup_time', now);

    print('✅ Auto backup completed');
  }
}

// ─────────────────────────────────────────────

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
