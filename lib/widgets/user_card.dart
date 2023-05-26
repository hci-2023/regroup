import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:regroup/models/user.dart';
import 'package:regroup/repository/user_repository.dart';

enum SampleItem { kickUser, promoteUser, demoteUser }

class UserCard extends StatelessWidget {
  final GroupUser user;
  final String groupId;
  final String currentUserRole;
  final bool showPhoto;
  final TextStyle boldStyle;

  late final UserRepository userRepository;
  late int userOrder;
  final splashColor = {
    'owner': Colors.blue[100],
    'moderator': Colors.grey[100],
    'participant': Colors.pink[100]
  };
  final userRoleValue = {'owner': 0, 'moderator': 1, 'participant': 2};

  UserCard(
      {Key? key,
      required this.user,
      required this.groupId,
      required this.currentUserRole,
      required this.showPhoto,
      required this.boldStyle})
      : super(key: key) {
    userRepository = UserRepository(groupId);
    userOrder = userRoleValue[user.role]!;

    if (user.isLost) {
      userOrder = -1;
    }
  }

  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Row(mainAxisSize: MainAxisSize.min, children: [
          _getUserIcon(context),
          const SizedBox(width: 14),
          Icon(
            user.isLost ? Icons.bluetooth_disabled : Icons.bluetooth_connected,
            color: user.isLost ? Colors.red : Colors.blue,
            size: 24.0,
          )
        ]),
        title: Text(user.username),
        subtitle: Text(user.role.capitalize()),
        trailing: currentUserRole == UserRole.owner.toShortString() &&
                    user.role != UserRole.owner.toShortString() ||
                currentUserRole == UserRole.moderator.toShortString() &&
                    user.role == UserRole.participant.toShortString()
            ? PopupMenuButton<SampleItem>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.blueAccent,
                ),
                initialValue: selectedMenu,
                // Callback that sets the selected popup menu item.
                onSelected: (SampleItem item) {
                  selectedMenu = item;
                },
                itemBuilder: (BuildContext context) => _getMenuEntry(user))
            : null,
      ),
    );
  }

  List<PopupMenuEntry<SampleItem>> _getMenuEntry(GroupUser user) {
    List<PopupMenuEntry<SampleItem>> entries = [
      PopupMenuItem<SampleItem>(
        value: SampleItem.kickUser,
        child: const Text('Kick'),
        onTap: () => userRepository.deleteUser(user.deviceId),
      ),
    ];

    if (user.role == UserRole.participant.toShortString()) {
      entries.add(PopupMenuItem<SampleItem>(
          value: SampleItem.promoteUser,
          child: const Text('Promote to moderator'),
          onTap: () {
            user.promote();
            userRepository.updateUser(user);
          }));
    } else if (user.role == UserRole.moderator.toShortString()) {
      entries.add(PopupMenuItem<SampleItem>(
          value: SampleItem.demoteUser,
          child: const Text('Demote to participant'),
          onTap: () {
            user.demote();
            userRepository.updateUser(user);
          }));
    }

    return entries;
  }

  Widget _getUserIcon(BuildContext context) {
    Widget userIcon;
    if (showPhoto && user.userPhotoUrl != null) {
      userIcon = GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (_) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Dialog(
                      child: Image.network(
                        user.userPhotoUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ));
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(user.userPhotoUrl!),
          radius: 24.0,
        ),
      );
    } else if (user.role == 'owner') {
      userIcon = IconButton(
        iconSize: 30.0,
        icon: const Icon(
          Icons.accessibility_new,
          color: Colors.pinkAccent,
        ),
        onPressed: () {},
      );
    } else if (user.role == 'moderator') {
      userIcon = IconButton(
        iconSize: 30.0,
        icon: const Icon(
          Icons.supervisor_account,
          color: Colors.blueAccent,
        ),
        onPressed: () {},
      );
    } else {
      userIcon = IconButton(
        iconSize: 30.0,
        icon: const Icon(
          Icons.person,
          color: Colors.blueGrey,
        ),
        onPressed: () {},
      );
    }
    return userIcon;
  }

  int get order {
    return userOrder;
  }
}
