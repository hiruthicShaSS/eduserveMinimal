// 🎯 Dart imports:
import 'dart:developer';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/global/service/birthday_service.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/providers/issue_provider.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/service/fees_details.dart';
import 'package:eduserveMinimal/service/get_hallticket.dart';
import 'package:eduserveMinimal/service/student_info.dart';
import 'package:eduserveMinimal/view/fees/fees.dart';
import 'package:eduserveMinimal/view/home/hallticket.dart';
import 'package:eduserveMinimal/view/home/internal_exams/internals_screen.dart';
import 'package:eduserveMinimal/view/home/timetable.dart';
import 'package:eduserveMinimal/view/home/widgets/home_screen.dart';
import 'package:eduserveMinimal/view/misc/birthday.dart';
import 'package:eduserveMinimal/view/misc/issues.dart';
import 'package:eduserveMinimal/view/settings/settings.dart';
import 'package:eduserveMinimal/view/user/user.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> _screens = [
    HomeScreen(),
    TimeTableScreen(),
    InternalMarksScreen(),
    UserScreen(),
  ];
  final PageController _pageController = PageController();
  bool _snackBarActive = false;
  late Future<User> userImageFuture;

  @override
  void initState() {
    userImageFuture = getStudentInfo();

    Sentry.addBreadcrumb(Breadcrumb(message: "Authenticated user"));

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Allow Notifications"),
            content: const Text(
                "We can send you notifications about upcoming classes..."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Don't Allow",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((isAllowed) {
                    if (isAllowed) Navigator.of(context).pop();
                  });
                },
                child: Text("Allow"),
              ),
            ],
          ),
        );
      }
    });

    processExcessInfo(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget defaultUserimage = Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Provider.of<ThemeProvider>(context).currentAppTheme ==
              AppTheme.valorant
          ? Image.asset(
              "assets/images/reyna-leer-loading.gif",
              width: 35,
              height: 30,
            )
          : Image.asset(
              "assets/placeholder_profile.png",
              width: 30,
              height: 30,
            ),
    );

    return Consumer2(
        builder: (context, AppState appState, IssueProvider issueProvider, _) {
      if (issueProvider.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          if (!_snackBarActive) {
            _snackBarActive = true;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(
                  "We found some issues!",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                duration: const Duration(seconds: 30),
                action: SnackBarAction(
                  label: "Review",
                  textColor: Colors.white,
                  onPressed: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => IssuesView()),
                      );

                      ScaffoldMessenger.of(context)
                          .removeCurrentMaterialBanner();
                    });
                  },
                ),
              ),
            );
          }
        });
      }

      return Scaffold(
        drawer: Drawer(
          child: Column(
            children: buildDrawer(context),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: (Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white)
              .withOpacity(0.6),
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuad,
            );
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_sharp), label: "Timetable"),
            BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Internals"),
            BottomNavigationBarItem(
              icon: Consumer(builder: (context, AppState appState, _) {
                return FutureBuilder(
                    future: userImageFuture,
                    builder: (context, AsyncSnapshot<User> snapshot) {
                      if (snapshot.hasError) {
                        log("Error fetching user image:",
                            error: snapshot.error);

                        if (snapshot.error.runtimeType == NetworkException) {
                          return defaultUserimage;
                        } else {
                          return defaultUserimage;
                        }
                      }

                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        appState.setUser = snapshot.data!;

                        return CircleAvatar(
                          maxRadius: 15,
                          backgroundImage:
                              MemoryImage(snapshot.data?.image ?? Uint8List(0)),
                          backgroundColor: Colors.transparent,
                          onBackgroundImageError: (_, __) => defaultUserimage,
                        );
                      }

                      return defaultUserimage;
                    });
              }),
              label: "Student",
            ),
          ],
        ),
      );
    });
  }

  List<StatelessWidget> buildDrawer(BuildContext context) {
    return [
      DrawerHeader(
        child: Center(
          child: Text("Hola amigo!", style: TextStyle(fontSize: 30)),
        ),
      ),
      ListTile(
        title: Text("Fees"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => FeesView())),
      ),
      ListTile(
        title: Text("Hallticket"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HallTicketView())),
      ),
      ListTile(
        title: Text("Settings"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Settings())),
      ),
      ListTile(
        title: Consumer(builder: (context, IssueProvider issueProvider, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Issues"),
              if (issueProvider.length > 0)
                Container(
                  height: 25,
                  width: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                  child: Text(
                    issueProvider.length.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        }),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => IssuesView())),
      ),
    ];
  }

  Future<void> processExcessInfo(BuildContext context) async {
    bool todayIsMyBirthDay = await checkBirthday();
    if (todayIsMyBirthDay) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BirthDayWidget()));
    }

    checkForIssues();

    try {
      if (!Provider.of<AppState>(context, listen: false).isTimetableCached) {
        await Provider.of<AppState>(context, listen: false).getTimetableData();
      }
    } on NetworkException {
    } on NoRecordsException {
    } on MiscellaneousErrorInEduserve catch (e) {
      log("Error pre-fetching timetable: ", error: e);
    }

    try {
      await Provider.of<CacheProvider>(context, listen: false)
          .getInternalAcademicTerms();
    } on NetworkException {
    } on NoRecordsException catch (e) {
      log("Error pre-fetching internal academic terms: ", error: e);
    }

    _checkUpdates(context);
  }

  Future<void> checkForIssues() async {
    IssueProvider issueProvider =
        Provider.of<IssueProvider>(context, listen: false);

    late Fees fees;
    HallTicket? hallTicket;

    try {
      fees = await getFeesDetails();
      if (fees.totalDues > 0) issueProvider.add(Issue.fees_due);
      if (mounted) {
        Provider.of<AppState>(context, listen: false).setFees = fees;
      }
    } on NetworkException {
      Fluttertoast.showToast(
          msg:
              "Few features will be disabled as there is no active internet connection. Restart the app to resume!");

      return;
    }

    try {
      await getHallTicket();
      if (hallTicket != null) {
        if (mounted) {
          Provider.of<AppState>(context, listen: false).setHallTicket =
              hallTicket;
        }

        if (!hallTicket.isEligibile && !hallTicket.isSubjectsEligibile) {
          issueProvider.add(Issue.hallticket_ineligible);
        }
      }
    } on NetworkException {
      Fluttertoast.showToast(
          msg:
              "Few features will be disabled as there is no active internet connection. Restart the app to resume!");

      return;
    } on MiscellaneousErrorInEduserve {}
  }

  void _checkUpdates(BuildContext context) async {
    if (!mounted) return;

    if (Provider.of<AppState>(context, listen: false).checkedForUpdate) return;

    PackageInfo info = await PackageInfo.fromPlatform();
    if (info.packageName.contains("dev") || info.packageName.contains("stg"))
      return;

    final newVersion = NewVersion(androidId: info.packageName);
    newVersion.showAlertIfNecessary(context: context);

    Provider.of<AppState>(context, listen: false).checkedForUpdate = true;
  }
}
