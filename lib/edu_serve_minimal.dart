// 🐦 Flutter imports:
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
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: flavor == "development",
        title: "eduserveMinimal",
        initialRoute: "/homeController",
        routes: {
          "/homeController": (BuildContext context) => const HomeController(),
          "/home": (BuildContext context) => const HomePage(),
          "/feedbackForm": (BuildContext context) => FeedbackForm(),
          "/timetable": (BuildContext context) => TimeTableScreen(),
          "/apply_leave": (BuildContext context) => const ApplyLeaveView(),
          "/fees": (BuildContext context) => FeesView(),
          "/credentials": (BuildContext context) => const Credentials(),
          "/user": (BuildContext context) => UserScreen(),
          "/forgotPassword": (BuildContext context) =>
              const ForgotPasswordScreen(),
          "/notifications": (BuildContext context) => const NotificationsView(),
          "/attributions": (BuildContext context) => const AttributionScreen(),
        },
        darkTheme: Provider.of<ThemeProvider>(context).getDarkTheme,
        themeMode: Provider.of<ThemeProvider>(context).themeMode,
        theme: Provider.of<ThemeProvider>(context).currentThemeData,
      ),
    );
  }
}
