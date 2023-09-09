import 'package:authenticator/screens/scan_qr_code.dart';
import 'package:authenticator/services/database/encryption_util.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:authenticator/services/database/database_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTOTPKeyScreen extends StatefulWidget {
  const AddTOTPKeyScreen({super.key});

  @override
  State<AddTOTPKeyScreen> createState() => _AddTOTPKeyScreenState();
}

class _AddTOTPKeyScreenState extends State<AddTOTPKeyScreen> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _nameControler = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final EncryptionUtils _encryptionUtils = EncryptionUtils();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _getKeyFromQrCode(BuildContext context) async {
    final List<String> result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const QrScanner()));

    if (result.length != 2) {
      if (!mounted) {
        return;
      }
      showDialog(context: context, builder: (context) => const AlertDialog());
      return;
    }

    final encryptionKey =
        await _secureStorage.read(key: EncryptionUtils.passKey);

    final iv = await _secureStorage.read(key: EncryptionUtils.ivKey);

    final encryptedKey = await _encryptionUtils.encryptData(
        result.elementAt(1), encryptionKey!, IV.fromBase64(iv!));

    await _databaseHelper.insertTOTP(
        {'totp_name': result.elementAt(0), 'secret_key': encryptedKey});
  }

  AlertDialog noNameAlert = const AlertDialog(
    title: Text("ERROR"),
    content: Text("There was an error with the QR code"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add TOTP Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameControler,
              decoration: const InputDecoration(
                labelText: 'TOTP Name',
              ),
            ),
            const Padding(padding: EdgeInsets.all(6)),
            TextFormField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'TOTP Key',
              ),
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final key = _keyController.text;

                final encryptionKey =
                    await _secureStorage.read(key: EncryptionUtils.passKey);

                final iv =
                    await _secureStorage.read(key: EncryptionUtils.ivKey);
                final encryptedKey = await _encryptionUtils.encryptData(
                    key, encryptionKey!, IV.fromBase64(iv!));

                final name = _nameControler.text;

                if (key.isNotEmpty && name.isNotEmpty) {
                  await _databaseHelper.insertTOTP(
                      {'totp_name': name, 'secret_key': encryptedKey});

                  if (!mounted) {
                    return;
                  }
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                      msg: "Please fill in all the fields",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: const Color(0xFF1DB954),
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: const Text(
                'Add Key',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _getKeyFromQrCode(context);
              },
              child: const Text(
                'Use qr code',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
