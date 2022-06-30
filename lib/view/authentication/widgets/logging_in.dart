// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoggingInScreen extends StatelessWidget {
  const LoggingInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = Provider.of<ThemeProvider>(context).currentAppTheme;
    Sentry.addBreadcrumb(Breadcrumb(message: "Authenticating user"));

    return Material(
      color: Theme.of(context).brightness != Brightness.light
          ? Theme.of(context).backgroundColor
          : null,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (appTheme == AppTheme.valorant)
              Image.asset("assets/images/kayo-loading.gif"),
            if (appTheme != AppTheme.valorant)
              Lottie.asset("assets/lottie/log_in.json"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Logging In...",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
