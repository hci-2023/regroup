import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:regroup/models/group.dart';
import 'package:regroup/repository/user_repository.dart';
import 'package:regroup/views/show_group.dart';
import 'package:provider/provider.dart';
import 'package:regroup/providers/user_provider.dart';
import 'package:regroup/utils.dart';
import 'package:regroup/models/user.dart';
import 'package:regroup/repository/group_repository.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final String title = "Create Group";
  GroupType _groupType = GroupType.bluetooth;
  double _distance = 50;
  bool showPhotos = true;
  bool _showLinearProgressIndicator = false;

  @override
  Widget build(BuildContext context) {
    Future<bool> createGroup() async {
      bool response = false;

      if (context.mounted) {
        String deviceId = context.read<User>().deviceId;
        String username = context.read<User>().username;
        File? userPhoto = context.read<User>().userPhoto;
        String? userPhotoUrl;

        if (showPhotos && userPhoto != null) {
          userPhotoUrl = await uploadPhoto(deviceId, userPhoto);
          if (context.mounted) {
            context.read<User>().setUserPhoto(null);
          }
        }

        await FirebaseMessaging.instance.setAutoInitEnabled(true);
        String? token = await FirebaseMessaging.instance.getToken();

        GroupRepository groupRepository = GroupRepository(deviceId);
        await groupRepository.addGroup(
            Group(groupId: deviceId, type: _groupType.toShortString(), showPhotos: showPhotos, distance: _groupType == GroupType.gps ? _distance : null));

        UserRepository userRepository = UserRepository(deviceId);
        await userRepository.addUser(
            GroupUser(deviceId: deviceId, username: username, role: UserRole.owner.toShortString(), lost: false, userPhotoUrl: userPhotoUrl, token: token));

        response = true;
      }
      return response;
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(title),
            leading: BackButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
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
        body: Center(
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.help),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text('Types of groups'),
                              content: SingleChildScrollView(
                                  child: ListBody(children: const <Widget>[
                                Text('The type of group you choose should depend on the distance you wish to have between group members.'),
                                SizedBox(height: 16),
                                Text(
                                    'You should choose a bluetooth type group if the maximum distance does not exceed 10 metres, otherwise if you need more distance choose a gps-based group.')
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
              ),
              ListTile(
                  title: const Text('Bluetooth'),
                  leading: Radio<GroupType>(
                    value: GroupType.bluetooth,
                    groupValue: _groupType,
                    onChanged: (GroupType? value) {
                      if (value != null) {
                        setState(() {
                          _groupType = value;
                        });
                      }
                    },
                  )),
              AbsorbPointer(
                child: ListTile(
                    title: const Text('Gps'),
                    leading: Radio<GroupType>(
                      value: GroupType.gps,
                      groupValue: _groupType,
                      onChanged: (GroupType? value) {
                        if (value != null) {
                          setState(() {
                            _groupType = value;
                          });
                        }
                      },
                    ),
                    enabled: false),
              ),
              if (_groupType == GroupType.gps)
                Column(children: <Widget>[
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.construction),
                    title: const Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.help),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('How does it work?'),
                                  content: SingleChildScrollView(
                                      child: ListBody(children: const <Widget>[
                                    Text('Set the maximum distance of group members, if exceeded alert the group.'),
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
                  ),
                  ListTile(
                    title: Slider(
                      value: _distance,
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: _distance.round().toString(),
                      onChanged: (double value) {
                        setState(() => _distance = value);
                      },
                    ),
                  ),
                ]),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.account_circle),
                title: Text(
                  "Show user's photo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                  title: const Text('Yes'),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: showPhotos,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          showPhotos = value;
                        });
                      }
                    },
                  )),
              ListTile(
                  title: const Text('No'),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: showPhotos,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          showPhotos = value;
                        });
                      }
                    },
                  )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => _showLinearProgressIndicator = !_showLinearProgressIndicator);
                    bool response = await createGroup();

                    if (response) {
                      if (context.mounted) {
                        showSnack(context, "Successfully created group");
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => ShowGroup(groupId: context.read<User>().deviceId, userId: context.read<User>().deviceId)),
                            (Route<dynamic> route) => false);
                      }
                    } else {
                      if (context.mounted) {
                        showSnack(context, "It was not possible to create a group");
                      }
                    }

                    if (mounted) {
                      setState(() => _showLinearProgressIndicator = !_showLinearProgressIndicator);
                    }
                  },
                  child: const Text('Create Group',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ));
  }
}
