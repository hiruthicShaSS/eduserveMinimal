// 🐦 Flutter imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/service/bg_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 📦 Package imports:
import 'package:sentry_flutter/sentry_flutter.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve_minimal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidOptions(encryptedSharedPreferences: true);

  await initializeService();

  AwesomeNotifications().initialize(
    "resource://drawable/res_notification_app_icon",
    notificationChannels,
  );

  await SentryFlutter.init(
    (options) {
      options.dsn =
          "https://5cf3e648046b4e67a059fc4d6b8fa0fd@o1022830.ingest.sentry.io/6010044";
    },
    appRunner: () => runApp(EduserveMinimal(flavor: "production")),
  );
}
