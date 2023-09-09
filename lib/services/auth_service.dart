import 'package:authenticator/services/database/database_helper.dart';
import 'package:authenticator/services/database/encryption_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class AuthService {
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _passwordKey = 'password';
  static const String _saltKey = 'salt';

  static const int _saltRounds = 12;

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final EncryptionUtils _encryptionUtils = EncryptionUtils();

  Future<bool> isPasswordSet() async {

    final passwordHash = await _secureStorage.read(key: _passwordKey);

    return passwordHash != null;
  }

  Future<void> setPassword(String password) async {

    final salt = await FlutterBcrypt.saltWithRounds(rounds: _saltRounds);

    final passwordHash = await FlutterBcrypt.hashPw(password: password, salt: salt);


    await _secureStorage.write(key: _passwordKey, value: passwordHash);
    await _secureStorage.write(key: _saltKey, value: salt);
  }

  Future<bool> validatePassword(String password) async {

    final hashedPass = await _secureStorage.read(key: _passwordKey);

    if (hashedPass == null) {
      return false;
    }

    final isValid = await FlutterBcrypt.verify(password: password, hash: hashedPass);

    if (isValid) {
      await generateAndStoreDatabaseKey(password);
    }
    return isValid;
  }


  Future<void> generateAndStoreDatabaseKey(String currentPass) async{

    final generatedKey = await _encryptionUtils.deriveKey(currentPass);

    final iv = _encryptionUtils.generateIV();

    final totpCodes = await _databaseHelper.getTOTPValues();

    for (var i = 0; i < totpCodes.length; i++) {
      
      final decryptedKey = await _encryptionUtils.decryptData(totpCodes[i]['secret_key']);

      final newEncryptedCode = await _encryptionUtils.encryptData(decryptedKey, generatedKey, iv);

      _databaseHelper.editTotpKeyRaw(i+1, newEncryptedCode);

    }

    await _secureStorage.write(key: EncryptionUtils.passKey, value: generatedKey);
    await _secureStorage.write(key: EncryptionUtils.ivKey, value: iv.base64);

  }


}