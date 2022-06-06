// 🐦 Flutter imports:
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/global/service/birthday_service.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/providers/issue_provider.dart';
import 'package:eduserveMinimal/providers/theme.dart';
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
  bool _snackBarActive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2(
        builder: (context, AppState appState, IssueProvider issueProvider, _) {
      if (issueProvider.isNotEmpty) {
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
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
                    SchedulerBinding.instance!
                        .addPostFrameCallback((timeStamp) {
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
          unselectedItemColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.4),
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
              AutoSizeText(
                "Hola amigo!",
                minFontSize: 20,
                maxFontSize: 25,
              ),
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
                                height: 100,
                                width: 100,
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                                child: Provider.of<ThemeProvider>(context)
                                            .currentAppTheme ==
                                        AppTheme.valorant
                                    ? Image.asset(
                                        "assets/images/reyna-leer-loading.gif")
                                    : CircularProgressIndicator(),
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

    try {
      getTimetable();
    } catch (_) {}

    Provider.of<CacheProvider>(context, listen: false)
        .getInternalAcademicTerms();

    checkForIssues();
    _checkUpdates(context);
  }

  Future<void> checkForIssues() async {
    IssueProvider issueProvider =
        Provider.of<IssueProvider>(context, listen: false);

    Fees fees = await getFeesDetails();
    HallTicket? hallTicket;

    try {
      await getHallTicket();
    } catch (_) {}

    if (mounted) {
      Provider.of<AppState>(context, listen: false).setFees = fees;
    }

    if (fees.totalDues > 0) issueProvider.add(Issue.fees_due);

    if (hallTicket != null) {
      if (mounted) {
        Provider.of<AppState>(context, listen: false).setHallTicket =
            hallTicket;
      }

      if (!hallTicket.isEligibile && !hallTicket.isSubjectsEligibile) {
        issueProvider.add(Issue.hallticket_ineligible);
      }
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
