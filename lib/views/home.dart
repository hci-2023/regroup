import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:provider/provider.dart';

import 'package:regroup/services/secure_local_storage.dart';
import 'package:regroup/models/secure_local_storage.dart';

import 'package:regroup/providers/user_provider.dart';
import 'package:regroup/services/device_information.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:regroup/services/firebase_utils.dart';
import 'package:regroup/utils.dart';

import 'package:regroup/views/show_group.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();
  bool _showLinearProgressIndicator = false;

  final FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialization());
  }

  void initialization() async {
    setState(() {
      _showLinearProgressIndicator = true;
    });

    String? deviceIdResponse = await _storageService.readSecureData('deviceId');

    if (deviceIdResponse == null) {
      deviceIdResponse = await getDeviceId();

      if (deviceIdResponse != null) {
        await _storageService.writeSecureData(StorageItem('deviceId', deviceIdResponse));
      }
    } else {
      if (context.mounted) {
        context.read<User>().setDeviceId(deviceIdResponse);
      }
    }

    String? usernameResponse = await _storageService.readSecureData('username');

    //await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();

    if (usernameResponse == null) {
      if (context.mounted) {
        await Navigator.pushReplacementNamed(context, "/intro");
      }
    } else {
      if (context.mounted) {
        context.read<User>().setUsername(usernameResponse);
      }
    }

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _bluetooth.requestPermissions();

    try {
      await FlutterBluetoothSerial.instance.requestEnable();
    } catch (_) {}

    String? groupId;
    groupId = await memberStatus(deviceIdResponse);

    if (groupId != null) {
      if (context.mounted) {
        showSnack(context, "You are already in a group, leave the current group to join or create a new one", durationInMilliseconds: 2000);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ShowGroup(groupId: groupId!, userId: context.read<User>().deviceId)),
            (Route<dynamic> route) => false);
      }
    }

    setState(() {
      _showLinearProgressIndicator = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: () => Navigator.pushNamed(context, "/userProfile"),
          ),
          iconTheme: const IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: _showLinearProgressIndicator == true
              ? const PreferredSize(
                  preferredSize: Size(double.infinity, 1.0),
                  child: LinearProgressIndicator(
                    color: Colors.black26,
                  ),
                )
              : null,
        ),
        body: AbsorbPointer(
          absorbing: _showLinearProgressIndicator,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: const BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Image.asset(
                          'assets/circle.png',
                          width: MediaQuery.of(context).size.width * 1,
                          height: MediaQuery.of(context).size.height * 0.3,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Align(
                        alignment: AlignmentDirectional(-0.8, 0),
                        child: AutoSizeText(
                          'Welcome,',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, "/createGroup"),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.54,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: BoxDecoration(
                          color: const Color(0xA82196F3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Text(
                            'Create group',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    splashColor: Colors.white,
                    onTap: () => Navigator.pushNamed(context, "/joinGroup"),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.54,
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                        color: const Color(0xA82196F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Text(
                          'Join group',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
