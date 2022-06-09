// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/providers/issue_provider.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/bg_service.dart';
import 'package:eduserveMinimal/view/feedback_form/feedback_form.dart';
import 'package:eduserveMinimal/view/fees/fees.dart';
import 'package:eduserveMinimal/view/home/apply_leave.dart';
import 'package:eduserveMinimal/view/home/home.dart';
import 'package:eduserveMinimal/view/home/semester_attendance_view.dart';
import 'package:eduserveMinimal/view/home/timetable.dart';
import 'package:eduserveMinimal/view/settings/attribution.dart';
import 'package:eduserveMinimal/view/settings/credentials.dart';
import 'package:eduserveMinimal/view/settings/forgot_password.dart';
import 'package:eduserveMinimal/view/settings/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/view/user/user.dart';
import 'package:eduserveMinimal/service/fill_feedback_form.dart';
import 'package:eduserveMinimal/service/get_feedback_form.dart';
import 'package:eduserveMinimal/shortcuts.dart';

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

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  @override
  void initState() {
    initQuickActions(context);
    initNotificationListeners();
    super.initState();
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
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data ?? false) {
                    return FutureBuilder(
                        future: _login(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            log("Error on edu_serve.dart",
                                error: snapshot.error);

                            if (snapshot.error.runtimeType == LoginError) {
                              return const Credentials();
                            }

                            if (snapshot.error.runtimeType ==
                                FeedbackFormFound) {
                              if (prefs.getInt("autoFillFeedbackValue") !=
                                  null) {
                                Provider.of<AppState>(context).setLoggedIn =
                                    true;

                                return const AutoFillFeedback();
                              }

                              Provider.of<AppState>(context).setLoggedIn = true;
                              return FeedbackForm();
                            }
                          }

                          initializeBackgroundService();

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Provider.of<AppState>(context).setLoggedIn = true;

                            return const HomePage();
                          }

                          AppTheme appTheme =
                              Provider.of<ThemeProvider>(context)
                                  .currentAppTheme;

                          return Material(
                            color:
                                Theme.of(context).brightness != Brightness.light
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
                            )),
                          );
                        });
                  }

                  return const Credentials();
                }

                return const Center(child: CircularProgressIndicator());
              });
        }

        return Container();
      },
    );
  }

  Future<bool> credentialsExist() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    bool userNameExist = await storage.read(key: "username") != null;
    bool passwordExist = await storage.read(key: "password") != null;

    return userNameExist && passwordExist;
  }

  Future _login() async {
    if (Provider.of<AppState>(context).isLoggedIn) return;

    return AuthService().login();
  }

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

  void initNotificationListeners() {
    try {
      AwesomeNotifications().actionStream.listen((notification) {
        if (notification.channelKey == absentNMotificationChannelKey) {
          DateTime yesterday = DateTime.fromMillisecondsSinceEpoch(
              int.parse(notification.payload!["date"]!));

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SemesterAttendanceView(
                yesterday: yesterday,
              ),
            ),
          );
        }
      });
    } catch (_) {}
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
