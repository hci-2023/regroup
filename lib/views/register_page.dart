import 'package:flutter/material.dart';
import 'package:regroup/services/secure_local_storage.dart';
import 'package:regroup/models/secure_local_storage.dart';
import 'package:regroup/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:regroup/views/allow_permissions.dart';
import 'package:regroup/utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final textFormFieldController = TextEditingController();
  bool _btnEnabled = false;

  @override
  void dispose() {
    textFormFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Image.asset("assets/register_info.png",
                          height: MediaQuery.of(context).size.height / 2),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Choose your username',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                              key: _formKey,
                              onChanged: () => setState(() => _btnEnabled =
                                  _formKey.currentState!.validate()),
                              child: TextFormField(
                                maxLength: 20,
                                controller: textFormFieldController,
                                validator: (value) => validateUsername(value),
                              ))),
                      ElevatedButton(
                          onPressed: _btnEnabled
                              ? () async {
                                  final username =
                                      textFormFieldController.text.trim();

                                  await _storageService.writeSecureData(
                                      StorageItem('username', username));

                                  if (context.mounted) {
                                    context.read<User>().setUsername(username);

                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AllowPermissions(),
                                        ),
                                        (route) => false);
                                  }
                                }
                              : null,
                          child: const Text("Register",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              )))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
