// Flutter imports:
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main(List<String> args) async {
  await SentryFlutter.init(
    (options) {
      options.debug = kDebugMode;
      options.dsn =
          'https://5cf3e648046b4e67a059fc4d6b8fa0fd@o1022830.ingest.sentry.io/6010044';
    },
    appRunner: () => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: EduServeMinimal(),
    )),
  );
}
