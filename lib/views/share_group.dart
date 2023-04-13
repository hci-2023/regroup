import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareGroup extends StatelessWidget {
  const ShareGroup({Key? key, required this.qrCodeData}) : super(key: key);

  final String qrCodeData;
  static const String title = "Share Group";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(title),
            leading: BackButton(
              color: Colors.white,
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
