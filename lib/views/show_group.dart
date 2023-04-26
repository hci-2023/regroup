import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:regroup/models/user.dart';
import 'package:regroup/repository/group_repository.dart';
import 'package:regroup/repository/user_repository.dart';
import 'package:regroup/repository/user_data_repository.dart';
import 'package:regroup/views/share_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regroup/widgets/user_card.dart';
import 'package:regroup/utils.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import 'dart:async';

class ShowGroup extends StatefulWidget {
  final String groupId;
  final String userId;
  const ShowGroup({Key? key, required this.groupId, required this.userId})
      : super(key: key);

  @override
  State<ShowGroup> createState() => _ShowGroupState();
}

class _ShowGroupState extends State<ShowGroup> {
  final String title = "Group";
  late final bool isOwner;
  late final StreamSubscription<DocumentSnapshot<Object?>> groupStream;
  late final StreamSubscription<DocumentSnapshot<Object?>> userStream;
  late final GroupRepository groupRepository;
  late final UserRepository userRepository;
  late final UserDataRepository userDataRepository;
  late final Stream<DocumentSnapshot<Object?>> groupDataStream;
  late final Stream<QuerySnapshot<Object?>> usersDataStream;
  late Map<String, dynamic> userInfo;

  final List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  bool isDiscovering = false;
  final FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();
  //nome del bluetooth
  String _nome = "";
  String _oldNome = "";
  // risultati vicini scansione [Nome, Indirizzo, rssi]
  List _risultati = [];

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
        ),
        iosConfiguration: IosConfiguration(
            //boh roba per ricchi
            ));
  }

  Future<void> onStart(ServiceInstance service) async {
    print("ONSTART");
    DartPluginRegistrant.ensureInitialized();
    Timer.periodic(const Duration(seconds: 30), (timer) {
      restartDiscovery();
    });
  }

  @override
  void initState() {
    isOwner = widget.groupId == widget.userId;
    groupRepository = GroupRepository(widget.groupId);
    userRepository = UserRepository(widget.groupId);
    userDataRepository = UserDataRepository(widget.groupId);

    var timerDiscovery = Timer.periodic(const Duration(seconds: 30), (timer) {
      restartDiscovery();
    });

    userStream = userRepository.getUserStream(widget.userId).listen((snapshot) {
      if (!snapshot.exists) {
        timerDiscovery.cancel();
        kickFromGroup();
      } else {
        userInfo = snapshot.data() as Map<String, dynamic>;
      }
    }, onError: (error) {
      //print(error);
    }, onDone: () {
      //print('Stream closed!');
    });

    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
    });

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          _showLinearProgressIndicator = false;
        }));

    groupDataStream = groupRepository.getStream();
    usersDataStream = userRepository.getStream();
  }

  @override
  void dispose() {
    userStream.cancel();
    super.dispose();
  }

  void kickFromGroup() {
    showSnack(context, "The group was deleted");
    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
  }

  void name() async {
    //abilita bluetooth se è disabilitato
    if (!_bluetoothState.isEnabled) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    FlutterBluetoothSerial.instance.name.then((name) {
      _oldNome = name!;
    });
    // cambia
    FlutterBluetoothSerial.instance.changeName(widget.userId);
    print("USERID${widget.userId}");
    print("USERID${widget.userId.runtimeType}");
    FlutterBluetoothSerial.instance.name.then((name) {
      print(name);
    });
  }

  // inizia scansione e stampa risultati
  void restartDiscovery() async {
    name();
    results.clear();
    isDiscovering = true;
    //inizia scansione
    startDiscovery();
    //aspetta la fine della scansione
    await Future.delayed(const Duration(seconds: 15));
    List finale = [_nome, _risultati];
    //print(finale);
    if (_risultati.isNotEmpty) {
      invia();
    }
    //fa partire la funzione che controlla che tutte le persone siano presenti
    if (isOwner) {
      //print(groupRepository.docId);
      groupRepository.checkNeighbours();
      //print("vicini controllati");
    }
    _risultati = [];
  }

  void startDiscovery() async {
    //richiede permessi
    await _bluetooth.requestPermissions();

    //attiva bluetooth se disattivato
    if (!_bluetoothState.isEnabled) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }
    //nome Dispositivo bluetooth
    FlutterBluetoothSerial.instance.name.then((name) {
      _nome = name!;
    });
    //inizia scansione
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final existingIndex = results
          .indexWhere((element) => element.device.address == r.device.address);
      if (existingIndex >= 0) {
        results[existingIndex] = r;
      } else {
        results.add(r);
      }
      //aggiunge i dispositivi vicini a _risultati
      //TODO aggiungere solo i dispositivi nel gruppo
      if (r.device.name != null) {
        _risultati.add(r.device.name);
      }
    });
    //scansione terminata
    _streamSubscription!.onDone(() async {
      await FlutterBluetoothSerial.instance.cancelDiscovery();
      isDiscovering = false;
      print("scansione terminata");
    });
  }

  void invia() {
    final dato = <String, dynamic>{"nome": _nome, "vicini": _risultati};
    userDataRepository.addUserData(widget.userId, dato);
    print("Inviato");
  }

  bool _showLinearProgressIndicator = true;

  final boldStyle =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(title),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Leave the group'),
                        content: SingleChildScrollView(
                            child: ListBody(children: const <Widget>[
                          Text(
                              'In order to return to the previous screen, you must first leave or delete the group.')
                        ])),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
            },
          ),
          bottom: _showLinearProgressIndicator == true
              ? PreferredSize(
                  preferredSize: const Size(double.infinity, 1.0),
                  child: LinearProgressIndicator(
                    color: Colors.blue[900],
                  ),
                )
              : null),
      body: AbsorbPointer(
        absorbing: _showLinearProgressIndicator,
        child: Center(
          child: StreamBuilder<DocumentSnapshot<Object?>>(
              stream: groupRepository.getStream(),
              builder: (context, snapshotGroup) {
                return StreamBuilder<QuerySnapshot>(
                    stream: userRepository.getStream(),
                    builder: (context, snapshotUsers) {
                      if (snapshotGroup.hasData &&
                          snapshotGroup.hasData &&
                          snapshotUsers.data != null &&
                          snapshotUsers.data != null &&
                          snapshotGroup.data!.data() != null) {
                        Map<String, dynamic> groupInfo =
                            snapshotGroup.data!.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: SizedBox(
                                      child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outlined,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                            'ID: ${groupInfo["accessIdentifier"]}')
                                      ],
                                    ),
                                  )),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                              text:
                                                  groupInfo["accessIdentifier"]
                                                      .toString()))
                                          .then((_) {
                                        showSnack(context,
                                            "Group id copied to clipboard");
                                      });
                                      // copied successfully
                                    },
                                    icon: const Icon(
                                      Icons.copy,
                                      color: Colors.blue,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShareGroup(
                                                qrCodeData: groupInfo[
                                                        "accessIdentifier"]
                                                    .toString())),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.qr_code,
                                      color: Colors.blue,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 20),
                            /*
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: SizedBox(
                                      child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          groupInfo["type"] == GroupType.gps.toShortString() ? Icons.gps_fixed : Icons.bluetooth,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(groupInfo["type"].toString().capitalize())
                                      ],
                                    ),
                                  )),
                                ),
                                if (groupInfo["type"] == GroupType.gps.toShortString())
                                  Card(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: SizedBox(
                                        child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.social_distance,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 10),
                                          Text('${groupInfo["distance"].toString()} m')
                                        ],
                                      ),
                                    )),
                                  )
                              ],
                            ),
                            const SizedBox(height: 25),
                            */
                            AbsorbPointer(
                              absorbing: !isOwner && userInfo['lost'],
                              child: ElevatedButton(
                                  onPressed: !isOwner && userInfo['lost']
                                      ? null
                                      : () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(isOwner
                                                      ? 'Delete group'
                                                      : "Leave group"),
                                                  content: Text(isOwner
                                                      ? 'Are you really sure you want to eliminate the group?'
                                                      : "Are you really sure you want to leave the group?"),
                                                  actions: [
                                                    TextButton(
                                                      child:
                                                          const Text("Cancel"),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                    TextButton(
                                                        child: const Text("Ok"),
                                                        onPressed: () async {
                                                          setState(() {
                                                            _showLinearProgressIndicator =
                                                                true;
                                                          });

                                                          if (isOwner) {
                                                            bool response =
                                                                await groupRepository
                                                                    .deleteGroup();

                                                            if (response ==
                                                                false) {
                                                              if (context
                                                                  .mounted) {
                                                                Navigator.pop(
                                                                    context);
                                                                showSnack(
                                                                    context,
                                                                    "The group could not be removed, please try again in a few moments",
                                                                    durationInMilliseconds:
                                                                        1500);
                                                              }
                                                            }
                                                          } else {
                                                            await userRepository
                                                                .deleteUser(
                                                                    widget
                                                                        .userId);
                                                            await deletePhoto(
                                                                widget.userId);
                                                          }

                                                          if (context.mounted) {
                                                            setState(() {
                                                              _showLinearProgressIndicator =
                                                                  false;
                                                            });
                                                          }
                                                        })
                                                  ],
                                                );
                                              });
                                        },
                                  child: Text(
                                      isOwner
                                          ? "Delete group"
                                          : "Leave the group",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ))),
                            ),
                            Expanded(
                                child: _buildList(
                                    context,
                                    snapshotUsers.data?.docs ?? [],
                                    groupInfo['showPhotos'])),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    });
              }),
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, List<DocumentSnapshot>? snapshot, bool showPhotos) {
    if (snapshot != null && snapshot.isNotEmpty) {
      var currentUser =
          snapshot.firstWhereOrNull((element) => element.id == widget.userId);

      if (currentUser != null) {
        var userInfo = currentUser.data() as Map<dynamic, dynamic>;
        var currentUserRole = userInfo['role'];

        List<UserCard> usersCard = snapshot
            .map((data) =>
                _buildListItem(context, data, currentUserRole, showPhotos))
            .toList();
        usersCard.sort((a, b) => a.userOrder.compareTo(b.userOrder));

        return ListView(
            padding: const EdgeInsets.only(top: 20.0),
            shrinkWrap: true,
            children: usersCard);
      }
    }

    return const SizedBox.shrink();
  }

  UserCard _buildListItem(BuildContext context, DocumentSnapshot snapshot,
      String currentUserRole, bool showPhoto) {
    final user = GroupUser.fromSnapshot(snapshot);

    return UserCard(
        user: user,
        groupId: widget.groupId,
        currentUserRole: currentUserRole,
        showPhoto: showPhoto,
        boldStyle: boldStyle);
  }
}
