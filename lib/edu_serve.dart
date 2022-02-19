// 🐦 Flutter imports:
import 'package:eduserveMinimal/service/fill_feedback_form.dart';
import 'package:eduserveMinimal/service/get_feedback_form.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/global/widgets/restart_widget.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/screens/home/pages/pages.dart';
import 'package:eduserveMinimal/screens/settings/pages/user.dart';
import 'package:eduserveMinimal/service/login.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/shortcuts.dart';

class eduserveMinimal extends StatelessWidget {
  eduserveMinimal({Key? key, this.flavor = "production"}) : super(key: key);
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
            SharedPreferences prefs = snapshot.data!;

            if (credentialsExist(prefs))
              return FutureBuilder(
                  future: isLoggedIn(prefs),
                  builder: (context, AsyncSnapshot<Map> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data!["isLoggedIn"]) {
                        if (snapshot.data!["feedBackFormFound"]) {
                          if (prefs.getInt("autoFillFeedbackValue") != null) {
                            return AutoFillFeedback();
                          }
                          return FeedbackForm();
                        }
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

  Future<Map> isLoggedIn(SharedPreferences prefs) async {
    Duration lastLogin = DateTime.parse(
            prefs.getString("lastLogin") ?? DateTime.now().toString())
        .difference(DateTime.now());

    if (lastLogin.inMinutes < 30 && Scraper.cache["home"] != null) {
      return {
        "isLoggedIn": true,
        "loginData": Scraper.cache["home"],
        "feedBackFormFound":
            Scraper.cache["home"].contains("feedback form found"),
        "loginError": false,
      };
    }

    String loginData = await login();
    await scraper.login();

    if (!loginData.contains("Login error"))
      prefs.setString("lastLogin", DateTime.now().toString());

    return {
      "isLoggedIn": loginData.length > 0,
      "loginData": loginData,
      "feedBackFormFound": loginData.contains("feedback form found"),
      "loginError": loginData.contains("Login error"),
    };
  }
}

class AutoFillFeedback extends StatelessWidget {
  const AutoFillFeedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: autoFill(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Navigator.of(context).pushNamed("/home");
          return SizedBox();
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset("assets/lottie/submitting_feedback.json"),
              Text("Sit tight, we are submitting your feedback form!"),
            ],
          ),
        );
      },
    );
  }

  Future<bool> autoFill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt("autoFillFeedbackValue") != null) {
      Map feedbackRating = {};
      List feedbackForm = await getFeedbackForm();

      for (final feedback in feedbackForm) {
        feedbackRating[feedback.last] = prefs.getInt("autoFillFeedbackValue");
      }

      bool feedBackFormFilled = await fillFeedbackForm(feedbackRating);

      if (feedBackFormFilled) return true;
    }

    return false;
  }
}
