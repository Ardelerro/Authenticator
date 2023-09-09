import 'package:authenticator/screens/add_totp_key_screen.dart';
import 'package:authenticator/screens/settings_screen.dart';
import 'package:authenticator/screens/totp_button_popup.dart';
import 'package:authenticator/services/database/encryption_util.dart';
import 'package:authenticator/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:authenticator/services/totp_service.dart';
import 'package:authenticator/services/database/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TOTPDisplayScreen extends StatefulWidget {
  const TOTPDisplayScreen({super.key});

  @override
  State<TOTPDisplayScreen> createState() => _TOTPDisplayScreenState();
}

class _TOTPDisplayScreenState extends State<TOTPDisplayScreen>
    with TickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final TOTPService _totpService = TOTPService();

  final EncryptionUtils _encryptionUtils = EncryptionUtils();

  late Timer _timer;

  double _progressValue = 1.0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateProgress();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    final timeStep = currentTime % TOTPService.getTimeStep();
    setState(() {
      _progressValue = 1 - (timeStep / TOTPService.getTimeStep());
    });
  }

  Future<void> copyKeyToClipboard(String code) async {
    Clipboard.setData(ClipboardData(text: code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TOTP Codes'), actions: <Widget>[
        IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings))
      ]),
      body: FutureBuilder(
        future: _databaseHelper.getTOTPValues(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Container(
              padding: EdgeInsets.zero,
              child: const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(left: 1.0),
                  child: Text(
                    'No TOTP keys available.',
                  ),
                ),
              ),
            );
          } else {
            final totpValues = snapshot.data as List<Map<String, dynamic>>;

            return ListView.builder(
              itemCount: totpValues.length,
              itemBuilder: (context, index) {
                final secretKey = totpValues[index]['secret_key'];
                final name = totpValues[index]['totp_name'];

                if (secretKey == null) {
                  return ListTile(
                    title: Text(name),
                    subtitle: const Text(
                        'Invalid secret key'), // Display a message for invalid keys
                  );
                }

                if (name == null) {
                  return const ListTile(title: Text('ERROR'));
                }

                return FutureBuilder(
                    future: _encryptionUtils.decryptData(secretKey),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('No TOTP key available.');
                      } else {
                        String totpCode =
                            _totpService.generateTOTP(snapshot.data as String);
                        return TextButton(
                          onPressed: () async {
                            await copyKeyToClipboard(totpCode);

                            Fluttertoast.showToast(
                                msg: "Code copied to clipboard",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: const Color(0xFF1DB954),
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                          onLongPress: (() {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    TotpPopupDialog().buildPopupDialog(
                                        context,
                                        name,
                                        index + 1,
                                        snapshot.data as String));
                          }),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                
                                children: [
                                  Consumer<ThemeProvider>(
                                      builder: (context, themeProvider, child) {
                                    return Flexible(
                                        fit: FlexFit.tight,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                      color: themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black
                                                    ),
                                                  )
                                            ),
                                            child: ListTile(
                                              title: Text(name),
                                              subtitle: Text(totpCode),
                                            )));
                                  }),
                                  CircularProgressIndicator(
                                    value: _progressValue,
                                    strokeWidth: 4.5,
                                  ),
                                  const SizedBox(width: 10.0, height: 5.0,)
                                ],
                              )
                            ],
                          ),
                        );
                      }
                    });
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTOTPKeyScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
