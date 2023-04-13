import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  String? deviceIdentifier;

  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    deviceIdentifier = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    deviceIdentifier = androidDeviceInfo.androidId; // unique ID on Android
  } else {
    var deviceInformation = await deviceInfo.deviceInfo;
    deviceIdentifier = deviceInformation.hashCode.toString();
  }

  return deviceIdentifier;
}
