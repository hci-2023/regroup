import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareGroup extends StatelessWidget {
  const ShareGroup({Key? key, required this.qrCodeData}) : super(key: key);

  final String qrCodeData;
  static const String title = "Share Group";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              title,
              style: TextStyle(color: Colors.blue),
            ),
            leading: BackButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: QrImage(
                    data: qrCodeData,
                    embeddedImage: const AssetImage("assets/share_logo.png"),
                    backgroundColor: Colors.white,
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(150, 150),
                    ),
                    errorCorrectionLevel: QrErrorCorrectLevel.H))));
  }
}
