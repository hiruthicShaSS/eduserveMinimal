// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';
import 'package:eduserveMinimal/views/creds.dart';
import 'package:eduserveMinimal/views/feedback_form.dart';
import 'package:eduserveMinimal/views/fees.dart';
import 'package:eduserveMinimal/views/hallticket.dart';
import 'package:eduserveMinimal/views/home_page.dart';
import 'package:eduserveMinimal/views/internals.dart';
import 'package:eduserveMinimal/views/settings.dart';
import 'package:eduserveMinimal/views/timetable.dart';
import 'package:eduserveMinimal/views/user.dart';

class EduServeMinimal extends StatelessWidget {
  const EduServeMinimal({Key key}) : super(key: key);

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
            .push(MaterialPageRoute(builder: (context) => Fees())),
      ),
      ListTile(
        title: Text("Internal"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => InternalMarks())),
      ),
      ListTile(
        title: Text("Hallticket"),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HallTicket())),
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
              return (snapshot.data.containsKey("username"))
                  ? FutureBuilder(
                      future: Provider.of<AppState>(context).scraper.login(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data == "feedback form found")
                            return FeedbackForm();
                          return HomePage();
                        }
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Logging In...",
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            CircularProgressIndicator(),
                          ],
                        ));
                      })
                  : Creds(pushHomePage: true);
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
