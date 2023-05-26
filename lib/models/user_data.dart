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

  Map<String, dynamic> _toJson() {
    return {
      'deviceId': deviceId,
      'neighbours': neighbours,
      'timestamp': timestamp
    };
  }
}
