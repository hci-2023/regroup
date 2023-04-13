class UserData {
  String deviceId;
  List<String> neighbours;
  String timestamp;

  UserData(
      {required this.deviceId,
      required this.neighbours,
      required this.timestamp});

  Map<String, dynamic> toJson() => _toJson();

  @override
  String toString() => 'UserData<$deviceId;$neighbours>';

  /*
  factory GroupUser.fromSnapshot(DocumentSnapshot snapshot) {
    final user = GroupUser.fromJson(snapshot.data() as Map<String, dynamic>);
    user.referenceId = snapshot.reference.id;
    return user;
  }
  */

  Map<String, dynamic> _toJson() {
    return {
      'deviceId': deviceId,
      'neighbours': neighbours,
      'timestamp': timestamp
    };
  }
}
