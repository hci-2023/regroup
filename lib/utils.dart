import 'package:flutter/material.dart';

void showSnack(BuildContext context, String text,
        {int durationInMilliseconds = 800}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(milliseconds: durationInMilliseconds),
      ),
    );

int groupIdToIdentifier(String groupId) {
  int accessIdentifier = 0;

  for (var element in groupId.codeUnits) {
    accessIdentifier = 2 * accessIdentifier + element;
  }

  return accessIdentifier;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty || value.length < 3) {
    return 'Must be at least 3 characters';
  }
  return null;
}
