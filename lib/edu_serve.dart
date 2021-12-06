// Flutter imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/global/widgets/restart_widget.dart';
import 'package:eduserveMinimal/screens/settings/pages/user.dart';
import 'package:eduserveMinimal/service/login.dart';
import 'package:eduserveMinimal/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/screens/home/pages/pages.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EduServeMinimal extends StatelessWidget {
  EduServeMinimal({Key? key, this.flavor = "production"}) : super(key: key);
  final String flavor;

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context)..initPlatformState();

    return MaterialApp(
      debugShowCheckedModeBanner: flavor == "development",
      home: HomeController(),
      routes: {
        "/home": (BuildContext context) => HomePage(),
        "/feedbackForm": (BuildContext context) => FeedbackForm(),
        "/timetable": (BuildContext context) => TimeTable(),
        "/apply_leave": (BuildContext context) => ApplyLeaveView(),
        "/fees": (BuildContext context) => FeesView(),
        "/credentials": (BuildContext context) => Credentials(),
        "/user": (BuildContext context) => User(),
      },
      darkTheme: ThemeProvider.dark,
      title: "eduserveMinimal",
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
    );
  }
}

class HomeController extends StatelessWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initQuickActions(context);

    return Scaffold(
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (credentialsExist(snapshot.data!))
              return FutureBuilder(
                  future: isLoggedIn(),
                  builder: (context, AsyncSnapshot<Map> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data!["isLoggedIn"]) {
                        if (snapshot.data!["feedBackFormFound"])
                          return FeedbackForm();
                        if (snapshot.data!["loginError"]) return Credentials();

                        return RestartWidget(child: HomePage());
                      }
                      return Credentials();
                    }

                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lottie/log_in.json"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Logging In...",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ],
                    ));
                  });
            return Credentials();
          }
          return Container();
        },
      ),
    );
  }

  void initQuickActions(BuildContext context) {
    final quickActions = QuickActions();
    quickActions.setShortcutItems(ShortcutItems.items);
  }

  bool credentialsExist(SharedPreferences prefs) =>
      prefs.containsKey("username") && prefs.containsKey("password");

  Future<Map> isLoggedIn() async {
    String loginData = await login();

    return {
      "isLoggedIn": loginData.length > 0,
      "loginData": loginData,
      "feedBackFormFound": loginData.contains("feedback form found"),
      "loginError": loginData.contains("Login error"),
    };
  }
}
