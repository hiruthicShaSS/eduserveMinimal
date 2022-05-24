// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/screens/home/pages/pages.dart';
import 'package:eduserveMinimal/screens/home/pages/user.dart';
import 'package:eduserveMinimal/service/fill_feedback_form.dart';
import 'package:eduserveMinimal/service/get_feedback_form.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/shortcuts.dart';

class eduserveMinimal extends StatelessWidget {
  eduserveMinimal({Key? key, this.flavor = "production"}) : super(key: key);
  final String flavor;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<CacheProvider>(create: (_) => CacheProvider()),
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: flavor == "development",
        home: HomeController(),
        routes: {
          "/home": (BuildContext context) => HomePage(),
          "/feedbackForm": (BuildContext context) => FeedbackForm(),
          "/timetable": (BuildContext context) => TimeTableView(),
          "/apply_leave": (BuildContext context) => ApplyLeaveView(),
          "/fees": (BuildContext context) => FeesView(),
          "/credentials": (BuildContext context) => Credentials(),
          "/user": (BuildContext context) => UserScreen(),
        },
        darkTheme: ThemeProvider.dark,
        title: "eduserveMinimal",
        themeMode: Provider.of<ThemeProvider>(context).themeMode,
      ),
    );
  }
}

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  void initQuickActionsEvents(BuildContext context) {
    final quickActions = QuickActions();
    quickActions.initialize((type) {
      print(type);

      switch (type) {
        case "timetable":
          Navigator.of(context).pushNamed("/timetable");
          break;
        case "fees":
          Navigator.of(context).pushNamed("/fees");
          break;
        case "apply_leave":
          Navigator.of(context).pushNamed("/apply_leave");
          break;
        case "user":
          Navigator.of(context).pushNamed("/user");
          break;
      }
    });
  }

  void initQuickActions(BuildContext context) {
    final quickActions = QuickActions();
    quickActions.setShortcutItems(ShortcutItems.items);
    initQuickActionsEvents(context);
  }

  @override
  void didChangeDependencies() {
    initQuickActions(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          SharedPreferences prefs = snapshot.data!;

          return FutureBuilder(
              future: credentialsExist(),
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data ?? false) {
                  return FutureBuilder(
                      future: isLoggedIn(prefs),
                      builder: (context, AsyncSnapshot<Map> snapshot) {
                        if (snapshot.hasError) {
                          log("Error on edu_serve.dart", error: snapshot.error);
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data!["isLoggedIn"]) {
                            if (snapshot.data!["feedBackFormFound"]) {
                              if (prefs.getInt("autoFillFeedbackValue") !=
                                  null) {
                                return AutoFillFeedback();
                              }
                              return FeedbackForm();
                            }
                            if (snapshot.data!["loginError"])
                              return Credentials();

                            return HomePage();
                          }

                          return Credentials();
                        }

                        return Material(
                          child: Center(
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
                          )),
                        );
                      });
                }

                return Credentials();
              });
        }
        return Container();
      },
    );
  }

  Future<bool> credentialsExist() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    bool userNameExist = await storage.containsKey(key: "username");
    bool passwordExist = await storage.containsKey(key: "password");

    return userNameExist && passwordExist;
  }

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

    String loginData = await AuthService().login();

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
    return Scaffold(
      body: FutureBuilder<bool>(
        future: autoFill(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Future.delayed(
                Duration.zero, () => Navigator.of(context).pushNamed("/home"));
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
      ),
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
