// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 📦 Package imports:
import 'package:sentry_flutter/sentry_flutter.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/edu_serve.dart';

void main() async {
  const AndroidOptions(encryptedSharedPreferences: true);

  await SentryFlutter.init(
    (options) {
      options.dsn =
          "https://5cf3e648046b4e67a059fc4d6b8fa0fd@o1022830.ingest.sentry.io/6010044";
    },
    appRunner: () => runApp(eduserveMinimal(flavor: "production")),
  );
}
