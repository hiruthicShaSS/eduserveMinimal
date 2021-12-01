// Flutter imports:
import 'package:eduserveMinimal/screens/home/widgets/attendance_summary_basic.dart';
import 'package:eduserveMinimal/screens/home/widgets/birthday.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

// Package imports:
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/screens/home/pages/credentials.dart';
import 'package:eduserveMinimal/screens/home/pages/feedback_form.dart';
import 'package:eduserveMinimal/screens/home/pages/fees.dart';
import 'package:eduserveMinimal/screens/home/pages/hallticket.dart';
import 'package:eduserveMinimal/screens/home/pages/internals.dart';
import 'package:eduserveMinimal/screens/home/pages/issues.dart';
import 'package:eduserveMinimal/screens/home/pages/settings.dart';
import 'package:eduserveMinimal/screens/home/pages/timetable.dart';
import 'package:eduserveMinimal/screens/home/widgets/attendance_widget.dart';
import 'package:eduserveMinimal/screens/home/widgets/leave_information.dart';
import 'package:eduserveMinimal/screens/settings/pages/user.dart';
import 'package:eduserveMinimal/service/downloadHallTicket.dart';
import 'package:eduserveMinimal/service/feesDetails.dart';
import 'package:eduserveMinimal/service/login.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/service/studentInfo.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    processExcessInfo(context);

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: buildDrawer(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.25,
            title: Text("eduserveMinimal"),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: AttendanceContainer(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              LeaveInformation(),
              AttendanceSummary(),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> checkBirthday(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("birthDay")) {
      String? birthday = prefs.getString("birthDay");

      if (birthday != null) {
        DateFormat dateFormat = DateFormat("dd MMM yyyy");
        DateTime birthDay = dateFormat.parse(birthday);
        DateTime today = DateTime.now();

        if (birthDay.month == today.month && birthDay.day == today.day) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => BirthDayWidget()));
        }
      }
    }
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
                      future: getInfo(),
                      builder: (context, AsyncSnapshot snapshot) {
                        return snapshot.hasData
                            ? CircleAvatar(
                                maxRadius: 50,
                                backgroundImage:
                                    MemoryImage(snapshot.data!["studentIMG"]),
                                backgroundColor: Colors.transparent,
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
                      .push(MaterialPageRoute(builder: (_) => User()));
                },
              ),
            ],
          ),
        ),
      ),
      ListTile(
        title: Text("Timetable"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TimeTable())),
      ),
      ListTile(
        title: Text("Fees"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => FeesView())),
      ),
      ListTile(
        title: Text("Internal"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => InternalMarks())),
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
    checkBirthday(context);
    _checkUpdates(context);
    
    Map dataCache = await fetchAllData();

    bool feesDue = (double.tryParse(dataCache["fees"]["dues"].first) ?? 0) > 0;
    bool hallTicketUnEligile = dataCache["hallticket"]
            .contains("No records to display.")
        ? false
        : dataCache["hallticket"].first.where((e) => e == "Eligible").length <
            3;

    print("Fees due: $feesDue");
    print("Uneligible for exam: $hallTicketUnEligile");

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
  }

  Future<Map> fetchAllData() async {
    await getFeesDetails();
    await getInfo();
    List? hallTicketData = await downloadHallTicket();
    if (hallTicketData != null) {
      await downloadHallTicket(
          term: hallTicketData[1].values.toList()[0]["value"]);
    }

    return Scraper.cache;
  }

  void _checkUpdates(BuildContext context) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    if (info.packageName.contains("dev") || info.packageName.contains("stg"))
      return;

    final newVersion = NewVersion(androidId: info.packageName);
    newVersion.showAlertIfNecessary(context: context);
    bool? canUpdate = (await newVersion.getVersionStatus())?.canUpdate;
    if (canUpdate ?? false)
      Fluttertoast.showToast(msg: "You are already on latest version!");
  }
}
