import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

import 'package:regroup/services/secure_local_storage.dart';
import 'package:regroup/models/secure_local_storage.dart';

import 'package:regroup/providers/user_provider.dart';
import 'package:regroup/services/device_information.dart';

import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
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
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

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
        await _storageService
            .writeSecureData(StorageItem('deviceId', deviceIdResponse));
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
      if (context.mounted)
        await Navigator.pushReplacementNamed(context, "/intro");
    } else {
      if (context.mounted) {
        context.read<User>().setUsername(usernameResponse);
      }
    }

    String? userPhotoLink =
        await _storageService.readSecureData('userPhotoLink');

    if (userPhotoLink != null) {
      if (context.mounted) {
        context.read<User>().setUserPhotoLink(userPhotoLink);
      }
    }

    await _bluetooth.requestPermissions();

    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (!_bluetoothState.isEnabled) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    // aggiungi funzione che controlla che il bluetooth sia attivo

    String? groupId;
    groupId = await memberStatus(deviceIdResponse);

    if (groupId != null) {
      if (context.mounted) {
        showSnack(context,
            "You are already in a group, leave the current group to join or create a new one",
            durationInMilliseconds: 2000);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ShowGroup(
                    groupId: groupId!, userId: context.read<User>().deviceId)),
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
        appBar: AppBar(
          bottom: _showLinearProgressIndicator == true
              ? PreferredSize(
                  preferredSize: const Size(double.infinity, 1.0),
                  child: LinearProgressIndicator(
                    color: Colors.blue[900],
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: const BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Image.asset(
                          'assets/title_black.png',
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Align(
                        alignment: AlignmentDirectional(-0.8, 0),
                        child: AutoSizeText(
                          'Welcome,',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w600),
                          maxLines: 2,
                        ),
                      ),
                      const Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(30, 20, 30, 20),
                          child: AutoSizeText(
                            'Create a group to keep track of all participants, or join an existing group',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
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
                    onTap: () => Navigator.pushNamed(context, "/createGroup"),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        color: const Color(0xA82196F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Text(
                          'Create group',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        color: const Color(0xA82196F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Text(
                          'Join group',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Welcome ${context.watch<User>().username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, "/userProfile");
              },
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('About us'),
            ),
          ],
        )));
  }
}
