import 'package:authenticator/services/database/encryption_util.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'your_app.db';
  static const _databaseVersion = 1;

  static const _totpTable = 'totp';
  static const _columnId = 'id';
  static const _columnSecretKey = 'secret_key';
  static const _coulmnTotpName = 'totp_name';

  static Database? _database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  final EncryptionUtils _encryptionUtils = EncryptionUtils();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final fullPath = join(path, _databaseName);

    return await openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_totpTable (
        $_columnId INTEGER PRIMARY KEY,
        $_coulmnTotpName TEXT NOT NULL,
        $_columnSecretKey TEXT NOT NULL
      )
    ''');
  }

  Future<void> removeTOTP(int id) async{
    final db = await database;
    await db.delete(_totpTable, where: '$_columnId = ?', whereArgs: [id]);
  }

  Future<void> insertTOTP(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert(_totpTable, row);
  }

  Future<List<Map<String, dynamic>>> getTOTPValues() async {
    final db = await database;
    final databaseTable = await db.query(_totpTable);
    return databaseTable;
  }

  Future<void> editTotpField(int id, String name, String key) async {
    final db = await database;

    final encryptionKey = await _secureStorage.read(key: EncryptionUtils.passKey);

    final iv = await _secureStorage.read(key: EncryptionUtils.ivKey);

    final encryptedKey = await _encryptionUtils.encryptData(key, encryptionKey!, IV.fromBase64(iv!));

    Map<String, dynamic> row = {_columnId : id, _coulmnTotpName : name, _columnSecretKey : encryptedKey};

    await db.update(_totpTable, row, where: '$_columnId = ?', whereArgs: [id]);
  }

  Future<void> editTotpName(int id, String name) async {

    final db = await database;

    await db.update(_totpTable, {_coulmnTotpName : name}, where: '$_columnId = ?', whereArgs: [id]);

  }

  Future<void> editTotpKey(int id, String key) async {

    final db = await database;

    final encryptionKey = await _secureStorage.read(key: EncryptionUtils.passKey);

    final iv = await _secureStorage.read(key: EncryptionUtils.ivKey);

    final encryptedKey = await _encryptionUtils.encryptData(key, encryptionKey!, IV.fromBase64(iv!));

    await db.update(_totpTable, {_columnSecretKey : encryptedKey}, where: '$_columnId = ?', whereArgs: [id]);

  }

    Future<void> editTotpKeyRaw(int id, String key) async {

    final db = await database;

    await db.update(_totpTable, {_columnSecretKey : key}, where: '$_columnId = ?', whereArgs: [id]);

  }

}