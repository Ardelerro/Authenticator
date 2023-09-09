import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';


class EncryptionUtils{

  static const String ivKey = "database_iv";
  static const String passKey = "database_key";


  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  Future<String> encryptData(String data, String encryptionKey, IV iv) async {

    final key = Key.fromBase64(encryptionKey);

    final encrypter = Encrypter(AES(key, mode: AESMode.sic, padding: null));
    final encrypted = encrypter.encrypt(data, iv: iv);


    return encrypted.base64;
  }

  IV generateIV(){

    return IV.fromSecureRandom(16);
  }

  Future<String> deriveKey(String masterKey) async {

    final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 10000, bits: 128);
    
    final salt = await FlutterBcrypt.saltWithRounds(rounds: 12);

    final derivedKeyGen = await pbkdf2.deriveKeyFromPassword(password: masterKey, nonce: utf8.encode(salt));

    final derivedKeyData = await derivedKeyGen.extractBytes();
    
    final derivedKey = base64.encode(derivedKeyData);

    return derivedKey;
    
  }

  Future<String> decryptData(String data) async {

    final encryptionKey = await _secureStorage.read(key: passKey);
    final key = Key.fromBase64(encryptionKey!);
    
    final iv = await _secureStorage.read(key: ivKey);
    
    final decrypter = Encrypter(AES(key, mode: AESMode.sic, padding: null));
    
    final encrypted = Encrypted.fromBase64(data); 
    final decrypted = decrypter.decrypt(encrypted, iv: IV.fromBase64(iv!));
    
    return decrypted;
  }
  


}