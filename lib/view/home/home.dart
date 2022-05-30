// 🐦 Flutter imports:
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/global/service/birthday_service.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/service/get_hallticket.dart';
import 'package:eduserveMinimal/service/timetable.dart';
import 'package:eduserveMinimal/view/home/widgets/home_screen.dart';
import 'package:eduserveMinimal/view/misc/issues.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/view/fees/fees.dart';
import 'package:eduserveMinimal/view/home/hallticket.dart';
import 'package:eduserveMinimal/view/home/internal_exams/internals_screen.dart';
import 'package:eduserveMinimal/view/settings/settings.dart';
import 'package:eduserveMinimal/view/home/timetable.dart';
import 'package:eduserveMinimal/view/misc/birthday.dart';
import 'package:eduserveMinimal/view/user/user.dart';
import 'package:eduserveMinimal/service/fees_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
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

  int _selectedIndex = 0;
  List<Widget> _screens = [
    HomeScreen(),
    TimeTableScreen(),
    InternalMarksScreen(),
    UserScreen(),
  ];
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, AppState appState, _) {
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
          unselectedItemColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
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
                icon: Icon(Icons.calendar_month_sharp),
                label: "Class Timetable"),
            BottomNavigationBarItem(
                icon: Icon(Icons.quiz), label: "Internal Marks"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Student"),
          ],
        ),
      );
    });
  }

  List<StatelessWidget> buildDrawer(BuildContext context) {
    return [
      DrawerHeader(
        child: Container(
          child: Row(
            children: [
              Text("Hola amigo!", style: TextStyle(fontSize: 25)),
              Spacer(),
              GestureDetector(
                child: Hero(
                  tag: "hero-userImage",
                  child: FutureBuilder(
                      future: Provider.of<AppState>(context).user,
                      builder: (context, AsyncSnapshot<User> snapshot) {
                        return snapshot.hasData
                            ? CircleAvatar(
                                maxRadius: 50,
                                backgroundImage: MemoryImage(
                                    snapshot.data?.image ?? Uint8List(0)),
                                backgroundColor: Colors.transparent,
                                onBackgroundImageError: (_, __) => Image.asset(
                                    "assets/placeholder_profile.png"),
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                                child: CircularProgressIndicator(),
                              );
                      }),
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => UserScreen()));
                },
              ),
            ],
          ),
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
    ];
  }

  Future<void> processExcessInfo(BuildContext context) async {
    bool todayIsMyBirthDay = await checkBirthday();
    if (todayIsMyBirthDay) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BirthDayWidget()));
    }

    getTimetable(supressError: true);
    checkForIssues();
    _checkUpdates(context);
  }

  Future<void> checkForIssues() async {
    Fees fees = await getFeesDetails();
    HallTicket hallTicket = await getHallTicket(suppressError: true);

    if (mounted) {
      Provider.of<AppState>(context, listen: false).setFees = fees;
      Provider.of<AppState>(context, listen: false).setHallTicket = hallTicket;
    }

    List<Issue> issues = [];

    if (fees.totalDues > 0) issues.add(Issue.fees_due);

    if (!hallTicket.isEligibile && !hallTicket.isSubjectsEligibile) {
      issues.add(Issue.hallticket_ineligible);
    }

    if (issues.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("We found some issues!"),
          duration: const Duration(seconds: 30),
          action: SnackBarAction(
            label: "Review",
            onPressed: () {
              SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => IssuesView(issues: issues)),
                );

                ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              });
            },
          ),
        ),
      );
    }
  }

  void _checkUpdates(BuildContext context) async {
    if (Provider.of<AppState>(context, listen: false).checkedForUpdate) return;

    PackageInfo info = await PackageInfo.fromPlatform();
    if (info.packageName.contains("dev") || info.packageName.contains("stg"))
      return;

    final newVersion = NewVersion(androidId: info.packageName);
    newVersion.showAlertIfNecessary(context: context);

    Provider.of<AppState>(context, listen: false).checkedForUpdate = true;
  }
}
