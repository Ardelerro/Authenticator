import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScanner();
}

class _QrScanner extends State<QrScanner>{

  List<String> _parseQrCode(String data){

    List<String> dataList = List.empty(growable: true);

    if (!data.contains("otpauth://totp")) {
      return List<String>.empty();
    }

    int secretStart = data.indexOf("secret=") +7;
    int secretEnd = data.indexOf("&");
    if (secretEnd <= 0) {
      secretEnd = data.length;
    }
    int nameStart = data.lastIndexOf("/") + 1;
    int nameEnd = data.indexOf("?");

    String secret = data.substring(secretStart, secretEnd);
    String name = data.substring(nameStart, nameEnd);

    dataList.add(name);
    dataList.add(secret);

    return dataList;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan TOTP code')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          Navigator.pop(context, _parseQrCode(barcodes.first.rawValue!));
        },
      ),
    );
  }

}