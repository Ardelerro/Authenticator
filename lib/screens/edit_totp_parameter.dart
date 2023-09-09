import 'package:authenticator/services/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TotpUpdateDialog {
  final TextEditingController _valControler = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Widget buildPopupDialog(
      BuildContext context, String name, int id, String key, bool toggle) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Text('Editing $name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _valControler,
            decoration: const InputDecoration(
              labelText: 'TOTP Value',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () async {
              final val = _valControler.text;
              if (val.isNotEmpty) {
                if (toggle) {
                  await _databaseHelper.editTotpName(id, val);
                } else {
                  await _databaseHelper.editTotpKey(id, val);
                }
                if (!context.mounted) {
                  return;
                }
                Navigator.pop(context);
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
            child: const Text('Submit Edit')),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
