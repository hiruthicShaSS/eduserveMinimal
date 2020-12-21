import 'dart:io';

import 'package:eduserveMinimal/views/creds.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

import 'package:eduserveMinimal/views/home.dart';
import 'package:eduserveMinimal/views/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'eduserveMinimal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.dark(),
      ),
      home: MyHomePage(title: "eduserve"),
      routes: {
        "/splashScreen": (context) => MyHomePage(),
        "/home": (context) => Home(),
        "/users": (context) => User(),
        "/updateCreds": (context) => Creds(),
      },
    ),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController _animationController;
  int _currentIndex = 0;

  final List<Widget> _children = [
    Home(),
    User(),
  ]; // Routes for navbar

  List<Widget> appBarActions =
      []; // For adding actions on the fly while switching pages via navbar

  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      HexColor("#833ab4"),
      HexColor("#fd1d1d"),
      HexColor("#fcb045")
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  Map cloudData = new Map(); // For holding the data downloaded from cloud
  Future<Map> downloadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username");
    String password = prefs.getString("password");
    int stars = prefs.getInt("stars");

    if ((username == null || password == null) ||
        (username == "" || password == "")) {
      Navigator.pushNamed(context, "/updateCreds");
    }

    Scraper scraper = new Scraper();
    Scraper.mainPageContext = context;
    Map data = await scraper.getInfo();
    cloudData = data;
    return data;
  }

  Future<void> refreshData() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File cacheData = File("$appDocPath/cacheData.json");
    cacheData.delete();
    setState(() {
      cloudData = new Map();
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget SplashScreen() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset("assets/splashscreen.json",
              controller: _animationController, onLoaded: (composition) {
            _animationController
              ..duration = composition.duration
              ..forward();
          }),

          // Text(Scraper.status),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey();
    var currentHour = DateTime.now().hour;

    return Scaffold(
      key: _mainScaffoldKey,
      appBar: AppBar(
        title: Text(
          "eduserveMinimal",
          style: TextStyle(foreground: Paint()..shader = linearGradient),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _mainScaffoldKey.currentState.openDrawer(),
        ),
        actions: (appBarActions.isEmpty)
            ? [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    refreshData();
                    Navigator.pushReplacementNamed(context, "/splashScreen");
                  },
                )
              ]
            : appBarActions,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/appIcon.png"),
                        radius: 30,
                      ),
                      Spacer(),
                      Text("Last Updated: 12-23-4566"),
                    ],
                  ),
                  Text(
                    (currentHour > 0 && currentHour < 12)
                        ? "Good Morning, buddy"
                        : (currentHour >= 12 && currentHour < 16)
                            ? "Good Afternoon"
                            : (currentHour >= 16 && currentHour < 20)
                                ? "Good Evening, amigo"
                                : "Go to bed",
                    style: GoogleFonts.comfortaa(
                        color: Colors.amberAccent,
                        fontSize: 20,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              title: Text("Fees"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text("Apply Leave"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text("Class Timetable"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text("Download Hall Ticket"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text("Internal Assessment"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: (cloudData.isEmpty)
          ? FutureBuilder(
              // Show loading page untill the data has downloaded
              future:
                  downloadData(), // Assigning the download function as the waiting target
              builder: (context, AsyncSnapshot<Map> snapshot) {
                if (snapshot.hasData) {
                  // If the cloudData has data then return home page
                  Home.cloudData = cloudData;
                  return _children[_currentIndex];
                } else {
                  return SplashScreen();
                }
              },
            )
          : _children[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.white38, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.supervised_user_circle),
                label: "User",
              ),
            ],
            selectedItemColor: Colors.amberAccent,
            unselectedItemColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    // Bottom navbar interaction's
    if (index == 1) {
      // user Page
      appBarActions.clear();
      appBarActions.add(IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Settings(),
              ));
        },
      ));
    } else if (index == 0) {
      // Home Page
      appBarActions.clear();
      appBarActions.add(IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          refreshData();
        },
      ));
    }

    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }
}
