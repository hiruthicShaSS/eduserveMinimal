// 🐦 Flutter imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/service/bg_service.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve_minimal.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidOptions(encryptedSharedPreferences: true);

  await initializeService();

  AwesomeNotifications().initialize(
    "resource://drawable/res_notification_app_icon",
    notificationChannels,
  );

  runApp(EduserveMinimal(flavor: "staging"));
}
