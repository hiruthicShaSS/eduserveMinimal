// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterConfig.loadEnvVariables();

  await SentryFlutter.init(
    (options) {
      options.dsn = FlutterConfig.get("SENTRY_DSN");
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
