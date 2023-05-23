import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:regroup/models/user.dart';
import 'package:regroup/repository/user_repository.dart';
import 'package:regroup/services/qr_code_scanner.dart';
import 'package:regroup/utils.dart';
import 'package:regroup/services/firebase_utils.dart';
import 'package:regroup/views/show_group.dart';
import 'package:provider/provider.dart';
import 'package:regroup/providers/user_provider.dart';

class JoinGroup extends StatefulWidget {
  const JoinGroup({super.key});

  @override
  State<JoinGroup> createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  final String title = "Join Group";
  final _formKey = GlobalKey<FormState>();
  final textFormFieldController = TextEditingController();

  bool _btnEnabled = false;
  bool _showLinearProgressIndicator = false;

  @override
  void dispose() {
    textFormFieldController.dispose();
    super.dispose();
  }

  String? _validateGroupId(String? value) {
    if (value?.isEmpty ?? false) {
      return 'Group id is required.';
    }
    final RegExp nameExp = RegExp(r'^[0-9]+$');
    if (!nameExp.hasMatch(value!)) {
      return 'Please enter only numerical characters.';
    }

    return null;
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRReader()),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => textFormFieldController.text = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          //title: Text(title),
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
              : null,
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              ListTile(
                title: const Text(
                  'Group id',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.help),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Insert the group id"),
                              content: SingleChildScrollView(
                                  child: ListBody(children: const <Widget>[
                                Text(
                                    "If you don't have the id, ask the group creator or a member within the group, you could also automatically enter the id by scanning the QR code provided to group members.")
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() => _btnEnabled = _formKey.currentState!.validate()),
                  child: TextFormField(
                    controller: textFormFieldController,
                    validator: _validateGroupId,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                          onPressed: () {
                            _navigateAndDisplaySelection(context);
                          }),
                      hintText: 'What is the group id?',
                      labelText: 'Id *',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _btnEnabled
                      ? () async {
                          setState(() => _showLinearProgressIndicator = !_showLinearProgressIndicator);

                          Map<String, dynamic> groupInfo = await isValidGroup(int.parse(textFormFieldController.text));

                          await FirebaseMessaging.instance.setAutoInitEnabled(true);
                          String? token = await FirebaseMessaging.instance.getToken();

                          if (groupInfo.isNotEmpty) {
                            String groupId = groupInfo['groupId'];
                            if (context.mounted) {
                              String? deviceId = context.read<User>().deviceId;
                              String? username = context.read<User>().username;
                              File? userPhoto = context.read<User>().userPhoto;
                              String? userPhotoLink;

                              if (groupInfo['showPhotos'] && userPhoto != null) {
                                userPhotoLink = await uploadPhoto(deviceId, userPhoto);
                                if (context.mounted) {
                                  context.read<User>().setUserPhoto(null);
                                }
                              }

                              UserRepository userRepository = UserRepository(groupId);
                              await userRepository.addUser(GroupUser(
                                  deviceId: deviceId,
                                  username: username,
                                  role: UserRole.participant.toShortString(),
                                  lost: false,
                                  userPhotoUrl: userPhotoLink,
                                  token: token));

                              if (context.mounted) {
                                await Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (BuildContext context) => ShowGroup(groupId: groupId, userId: context.read<User>().deviceId)),
                                    (Route<dynamic> route) => false);
                              }
                            }
                          }

                          if (context.mounted) {
                            setState(() => _showLinearProgressIndicator = !_showLinearProgressIndicator);
                            showSnack(context, "The group does not exist");
                          }
                        }
                      : null,
                  child: const Text('Join Group', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ));
  }
}
