// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/global/widgets/network_aware_widget.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/bg_service.dart';
import 'package:eduserveMinimal/shortcuts.dart';
import 'package:eduserveMinimal/view/authentication/widgets/auto_fill_feedback_form.dart';
import 'package:eduserveMinimal/view/authentication/widgets/logging_in.dart';
import 'package:eduserveMinimal/view/home/semester_attendance_view.dart';
import 'package:eduserveMinimal/view/misc/no_internet_screen.dart';
import 'authentication/credentials.dart';
import 'feedback_form/feedback_form.dart';
import 'home/home.dart';

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

          return NetworkAwareWidget(
            noInternetWidget: const NoInternetScreen(),
            removeAwarenessAfterConnection: true,
            showDialogWhenOffline: true,
            child: FutureBuilder(
                future: credentialsExist(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data ?? false) {
                      return Consumer(builder: (context, AppState appState, _) {
                        return FutureBuilder(
                          future: _login(appState),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              log("Error on edu_serve.dart",
                                  error: snapshot.error);

                              switch (snapshot.error.runtimeType) {
                                case NetworkException:
                                  return const NoInternetScreen();
                                case LoginError:
                                  return const Credentials();
                                case FeedbackFormFound:
                                  if (prefs.getInt("autoFillFeedbackValue") !=
                                      null) {
                                    appState.setLoggedIn = true;

                                    return const AutoFillFeedback();
                                  }

                                  appState.setLoggedIn = true;
                                  return FeedbackForm();
                              }
                            }

                            initializeBackgroundService();

                            bool isAlreadyLoggedIn = appState.isLoggedIn;

                            if (snapshot.connectionState ==
                                    ConnectionState.done ||
                                isAlreadyLoggedIn) {
                              appState.setLoggedIn = true;

                              return const HomePage();
                            }

                            return LoggingInScreen();
                          },
                        );
                      });
                    }

                    return const Credentials();
                  }

                  return const Center(child: CircularProgressIndicator());
                }),
          );
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

  Future _login(AppState appState) async {
    if (appState.isLoggedIn) return;

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
        if (notification.channelKey == kAbsentNotificationChannelKey) {
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
