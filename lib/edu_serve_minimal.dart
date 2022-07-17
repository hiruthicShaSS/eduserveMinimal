// 🐦 Flutter imports:
import 'package:eduserveMinimal/providers/restart_provider.dart';
import 'package:eduserveMinimal/view/settings/privacy.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/providers/issue_provider.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/view/authentication/credentials.dart';
import 'package:eduserveMinimal/view/authentication/forgot_password.dart';
import 'package:eduserveMinimal/view/feedback_form/feedback_form.dart';
import 'package:eduserveMinimal/view/fees/fees.dart';
import 'package:eduserveMinimal/view/home/apply_leave.dart';
import 'package:eduserveMinimal/view/home/home.dart';
import 'package:eduserveMinimal/view/home/timetable.dart';
import 'package:eduserveMinimal/view/settings/attribution.dart';
import 'package:eduserveMinimal/view/settings/notifications.dart';
import 'package:eduserveMinimal/view/user/user.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'view/home_screen_controller.dart';

class EduserveMinimal extends StatelessWidget {
  EduserveMinimal({Key? key, this.flavor = "production"}) : super(key: key);
  final String flavor;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<CacheProvider>(create: (_) => CacheProvider()),
        ChangeNotifierProvider<IssueProvider>(create: (_) => IssueProvider()),
        ChangeNotifierProvider<RestartProvider>(
            create: (_) => RestartProvider()),
      ],
      builder: (context, child) =>
          Consumer(builder: (_, RestartProvider restartProvider, __) {
        return MaterialApp(
          key: UniqueKey(),
          debugShowCheckedModeBanner: flavor == "development",
          title: "eduserveMinimal",
          initialRoute: "/homeController",
          darkTheme: Provider.of<ThemeProvider>(context).getDarkTheme,
          themeMode: Provider.of<ThemeProvider>(context).themeMode,
          theme: Provider.of<ThemeProvider>(context).currentThemeData,
          routes: {
            "/homeController": (_) => const HomeController(),
            "/home": (_) => const HomePage(),
            "/feedbackForm": (_) => FeedbackForm(),
            "/timetable": (_) => TimeTableScreen(),
            "/apply_leave": (_) => const ApplyLeaveView(),
            "/fees": (_) => FeesView(),
            "/credentials": (_) => const Credentials(),
            "/user": (_) => UserScreen(),
            "/forgotPassword": (_) => const ForgotPasswordScreen(),
            "/notifications": (_) => const NotificationsView(),
            "/attributions": (_) => const AttributionScreen(),
            "/privacy": (_) => const PrivacyScreen(),
          },
          navigatorObservers: [SentryNavigatorObserver()],
        );
      }),
    );
  }
}
