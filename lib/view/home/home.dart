// 🐦 Flutter imports:
import 'dart:typed_data';

import 'package:eduserveMinimal/global/service/birthday_service.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/timetable.dart';
import 'package:eduserveMinimal/view/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:html/dom.dart' as dom;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/view/fees/fees.dart';
import 'package:eduserveMinimal/view/home/hallticket.dart';
import 'package:eduserveMinimal/view/home/internal_exams/internals_screen.dart';
import 'package:eduserveMinimal/view/misc/issues.dart';
import 'package:eduserveMinimal/view/settings/settings.dart';
import 'package:eduserveMinimal/view/home/timetable.dart';
import 'package:eduserveMinimal/view/misc/birthday.dart';
import 'package:eduserveMinimal/view/settings/user.dart';
import 'package:eduserveMinimal/service/download_hallticket.dart';
import 'package:eduserveMinimal/service/fees_details.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/service/student_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
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

    try {
      getTimetable();
    } catch (_) {}
    _checkUpdates(context);

    Map dataCache = await fetchAllData();

    try {
      bool feesDue =
          (double.tryParse(dataCache["fees"]["dues"].first) ?? 0) > 0;
      bool hallTicketUnEligile = dataCache["hallticket"]
              .contains("No records to display.")
          ? false
          : dataCache["hallticket"].first.where((e) => e == "Eligible").length <
              3;

      if (feesDue || hallTicketUnEligile) {
        ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          backgroundColor: Colors.redAccent,
          leading: Icon(Icons.error_outline),
          content: TextButton(
              onPressed: () {
                SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => IssuesView(
                          outstandingDue: feesDue,
                          hallTicketUnEligible: hallTicketUnEligile)));
                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                });
              },
              child: Text("Action required!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold))),
          actions: [
            IconButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).removeCurrentMaterialBanner(),
                icon: Icon(Icons.close)),
          ],
        ));
      }
    } catch (e) {}
  }

  Future<Map> fetchAllData() async {
    await getFeesDetails();
    await getStudentInfo();
    List? hallTicketData = await downloadHallTicket();
    if (hallTicketData != null) {
      await downloadHallTicket(
          term: hallTicketData[1].values.toList()[0]["value"]);
    }

    return Scraper.cache;
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
