// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  const AndroidOptions(encryptedSharedPreferences: true);

  runApp(eduserveMinimal(flavor: "development"));
}
