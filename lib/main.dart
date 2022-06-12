// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve_minimal.dart';
import 'package:eduserveMinimal/global/constants.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidOptions(encryptedSharedPreferences: true);

  AwesomeNotifications().initialize(
    "resource://drawable/res_notification_app_icon",
    notificationChannels,
  );

  runApp(EduserveMinimal());
}
