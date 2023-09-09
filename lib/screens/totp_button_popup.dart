import 'package:authenticator/screens/edit_totp_parameter.dart';
import 'package:authenticator/services/database/database_helper.dart';
import 'package:flutter/material.dart';

class TotpPopupDialog{

  void deleteAction(int id, BuildContext context){
    DatabaseHelper.instance.removeTOTP(id);
    Navigator.of(context).pop();
  }

  Widget buildPopupDialog(BuildContext context, String name, int id, String key) {
    return AlertDialog(
      title: Text('Editing $name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextButton(onPressed: (() {
            showDialog(
              context: context, 
              builder: (BuildContext context) => TotpUpdateDialog().buildPopupDialog(context, name, id, key, true)
            );
            }),
            child: const Text('Edit Name')),
          TextButton(onPressed: (() {
            showDialog(
              context: context, 
              builder: (BuildContext context) => TotpUpdateDialog().buildPopupDialog(context, name, id, key, false)
            );
            }), child: const Text('Edit Key')),
          TextButton(onPressed: () => deleteAction(id, context), child: const Text('Delete', style: TextStyle(color: Color.fromARGB(255, 211, 47, 47)))),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}