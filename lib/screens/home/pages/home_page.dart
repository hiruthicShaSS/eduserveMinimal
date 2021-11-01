// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Package imports:
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/screens/home/pages/creds.dart';
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
    var drawer = [
      DrawerHeader(
        child: Container(
          child: Row(
            children: [
              Text("Hola amigo!", style: TextStyle(fontSize: 25)),
              Spacer(),
              GestureDetector(
                child: Hero(
                  tag: "hero-userImage",
                  child: CircleAvatar(
                    maxRadius: 50,
                    backgroundImage: AssetImage("assets/appIcon.png"),
                    backgroundColor: Colors.transparent,
                  ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("eduserveMinimal"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: drawer,
        ),
      ),
      body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context,
              AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return (snapshot.data!.containsKey("username"))
                  ? FutureBuilder(
                      future: login(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data == "feedback form found")
                            return FeedbackForm();
                          if (snapshot.data == "Login error")
                            return Creds(pushHomePage: true);

                          processExcessInfo(context);

                          return Column(
                            children: [
                              AttendanceContainer(),
                              LeaveInformation(),
                            ],
                          );
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
                      })
                  : Creds(pushHomePage: true);
            }
            return CircularProgressIndicator();
          }),
    );
  }

  Future<void> processExcessInfo(BuildContext context) async {
    _checkUpdates(context);
    Map dataCache = await fetchAllData();

    bool feesDue = (double.tryParse(dataCache["fees"]["dues"].first) ?? 0) > 0;
    bool hallTicketUnEligile =
        dataCache["hallticket"].first.where((e) => e == "Eligible").length < 3;

    print(feesDue);
    print(hallTicketUnEligile);

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
