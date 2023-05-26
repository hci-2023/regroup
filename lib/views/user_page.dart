import 'package:flutter/material.dart';
import 'package:regroup/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);
  static const String title = "Profile";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: BackButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Center(
          child: ListView(
            children: [
              const ListTile(
                trailing: Icon(Icons.face),
                title: Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                  title: Text(context.watch<User>().username,
                      style: const TextStyle(
                        fontSize: 20,
                      ))),
              const Divider(),
              const ListTile(
                trailing: Icon(Icons.smartphone),
                title: Text(
                  'Device Identifier',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  context.watch<User>().deviceId,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const Divider(),
            ],
          ),
        ));
  }
}
