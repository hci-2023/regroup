import 'package:regroup/utils.dart';

enum GroupType { bluetooth, gps }

extension ParseToString on GroupType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Group {
  final String groupId;
  late final int accessIdentifier;
  final String type;
  final bool showPhotos;
  double? distance;

  Group({
    required this.groupId,
    required this.type,
    required this.showPhotos,
    this.distance,
  }) : accessIdentifier = groupIdToIdentifier(groupId);

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'],
      type: json["type"],
      showPhotos: json["showPhotos"],
      distance: json.containsKey('distance') ? json["distance"] : null,
    );
  }

  Map<String, dynamic> toJson() => _toJson();

  @override
  String toString() =>
      'Group<$groupId;$accessIdentifier;$type;${distance ?? ";${distance!}"}}>';

  Map<String, dynamic> _toJson() {
    Map<String, dynamic> data = {
      'groupId': groupId,
      'accessIdentifier': accessIdentifier,
      'type': type,
      'showPhotos': showPhotos
    };

    if (distance != null) {
      data['distance'] = distance;
    }

    return data;
  }

  GroupType roleToEnum() {
    return GroupType.values.firstWhere((e) => e.toShortString() == type);
  }
}
