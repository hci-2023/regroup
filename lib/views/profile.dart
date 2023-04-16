import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regroup/providers/user_provider.dart';
import 'package:regroup/models/secure_local_storage.dart';
import 'package:regroup/services/secure_local_storage.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  bool _isReadonly = true;
  var focusNode = FocusNode();
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  final storageRef = FirebaseStorage.instance.ref();
  bool _showLinearProgressIndicator = false;
  String? userPhotoLink;
  String? deviceId;
  var submit = true;
  var lastUsername = "";
  var check = true;
  Widget checkIcon =
      const Icon(Icons.check_rounded, color: Colors.blueAccent, size: 30);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (check) {
      _controller.text = context.watch<User>().username;
      deviceId = context.watch<User>().deviceId;
      userPhotoLink = context.watch<User>().userPhotoLink;
      lastUsername = _controller.text;
      check = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
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
      body: AbsorbPointer(
        absorbing: _showLinearProgressIndicator,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 40),
                  child: Stack(
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: InkWell(
                          child: Material(
                            color: Colors.transparent,
                            elevation: 4,
                            shape: const CircleBorder(),
                            child: ClipOval(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.7,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: userPhotoLink == null
                                    ? Image.asset(
                                        'assets/profile.png',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        userPhotoLink!,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.error_outline);
                                        },
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.65, 0),
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _showLinearProgressIndicator = true;
                            });

                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                maxHeight: 900,
                                maxWidth: 600,
                                imageQuality: 50);
                            File imageFile;

                            if (image != null) {
                              imageFile = File(image.path);

                              if (deviceId != null) {
                                final userPhotoRef =
                                    storageRef.child("images/$deviceId.jpg");

                                await userPhotoRef
                                    .putFile(imageFile)
                                    .then((p0) async {
                                  if (userPhotoLink == null) {
                                    String photoUrl =
                                        await userPhotoRef.getDownloadURL();
                                    userPhotoLink = photoUrl;

                                    await _storageService.writeSecureData(
                                        StorageItem('userPhotoLink', photoUrl));

                                    if (context.mounted) {
                                      context
                                          .read<User>()
                                          .setUserPhotoLink(photoUrl);
                                    }
                                  }

                                  if (context.mounted) {
                                    setState(() {
                                      userPhotoLink = "$userPhotoLink ";
                                    });
                                  }
                                });
                              }
                            }

                            if (context.mounted) {
                              setState(() {
                                _showLinearProgressIndicator = false;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.73,
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.73,
                          child: Form(
                            key: _formKey,
                            onChanged: () => setState(() {
                              submit = _formKey.currentState!.validate();
                              if (!submit) {
                                checkIcon = const Icon(Icons.check_rounded,
                                    color: Colors.red, size: 30);
                              } else {
                                checkIcon = const Icon(Icons.check_rounded,
                                    color: Colors.blueAccent, size: 30);
                              }
                            }),
                            child: TextFormField(
                              maxLength: 20,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 3) {
                                  return 'Must be at least 3 characters';
                                }
                                return null;
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              controller: _controller,
                              obscureText: false,
                              readOnly: _isReadonly,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Username',
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                    color: Color(0xFF57636C)),
                                contentPadding:
                                    EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              ),
                              style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(1.2, 0),
                          child: TextButton(
                            style: const ButtonStyle(
                                splashFactory: NoSplash.splashFactory,
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white)),
                            onPressed: () async {
                              submit
                                  ? {
                                      (_isReadonly)
                                          ? FocusScope.of(context).unfocus()
                                          : FocusScope.of(context)
                                              .requestFocus(focusNode),
                                      if (_formKey.currentState!.validate() &
                                          (_controller.text != lastUsername))
                                        {
                                          lastUsername =
                                              _controller.text.trim(),
                                          await _storageService.writeSecureData(
                                              StorageItem(
                                                  'username', lastUsername)),
                                          if (context.mounted)
                                            {
                                              context
                                                  .read<User>()
                                                  .setUsername(lastUsername)
                                            }
                                        },
                                      setState(() {
                                        _isReadonly = !_isReadonly;
                                      }),
                                    }
                                  : null;
                            },
                            child: (_isReadonly)
                                ? const Icon(
                                    Icons.mode_rounded,
                                    color: Color(0xFF57636C),
                                    size: 30,
                                  )
                                : checkIcon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
