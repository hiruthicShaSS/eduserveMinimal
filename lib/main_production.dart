// 🐦 Flutter imports:
import 'package:eduserveMinimal/models/user.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve_minimal.dart';
import 'package:eduserveMinimal/global/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidOptions(encryptedSharedPreferences: true);

  AwesomeNotifications().initialize(
    "resource://drawable/res_notification_app_icon",
    notificationChannels,
  );

  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  final bool _attachRegisterNumberToCrashLogs =
      _prefs.getBool(kAttachRegisterNumberToCrashLogs) ?? false;
  final bool _attachKmailToCrashLogs =
      _prefs.getBool(kAttachKmailToCrashLogs) ?? false;
  final bool _attachNameToCrashLogs =
      _prefs.getBool(kAttachNameToCrashLogs) ?? false;

  SentryUser? _sentryUser;
  if (await _storage.containsKey(key: kStorage_key_userData)) {
    String? userDataString = await _storage.read(key: kStorage_key_userData);

    if (userDataString != null) {
      User user = User.fromJson(userDataString);

      if (_attachRegisterNumberToCrashLogs ||
          _attachNameToCrashLogs ||
          _attachKmailToCrashLogs) {
        _sentryUser = SentryUser(
          id: _attachRegisterNumberToCrashLogs ? user.registerNumber : null,
          username: _attachNameToCrashLogs ? user.name : null,
          email: _attachKmailToCrashLogs ? user.kmail : null,
        );
      }
    }
  }

  await SentryFlutter.init(
    (options) async {
      PackageInfo info = await PackageInfo.fromPlatform();

      options
        ..dsn =
            "https://5cf3e648046b4e67a059fc4d6b8fa0fd@o1022830.ingest.sentry.io/6010044"
        ..release = info.version + "+" + info.buildNumber
        ..enableAutoSessionTracking
        ..beforeSend = (event, {hint}) async {
          event = event.copyWith(user: _sentryUser);

          return event;
        };
    },
    appRunner: () => runApp(EduserveMinimal(flavor: "production")),
  );
}
