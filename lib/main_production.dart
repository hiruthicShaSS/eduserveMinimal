import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://5cf3e648046b4e67a059fc4d6b8fa0fd@o1022830.ingest.sentry.io/6010044';
    },
    appRunner: () => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const EduServeMinimal(flavor: "production"),
    )),
  );
}
