import 'package:eduserveMinimal/creds.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:eduserveMinimal/settings.dart';
import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

import 'package:eduserveMinimal/home.dart';
import 'package:eduserveMinimal/user.dart';
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

    if (username == null || password == null) {
      Navigator.pushNamed(context, "/updateCreds");
    }

    Scraper scraper = new Scraper();
    Scraper.mainPageContext = context;
    Map data = await scraper.getInfo();
    cloudData = data;
    return data;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  Widget SplashScreen() {
    return Container(
      child: ListView(
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "eduserveMinimal",
          style: TextStyle(foreground: Paint()..shader = linearGradient),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: appBarActions,
      ),
      body: FutureBuilder(
        // Show loading page untill the data has downloaded
        future:
            downloadData(), // Assigning the download function as the waiting target
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            // If the cloudData has data then return home page
            Home.cloudData = cloudData;
            return _children[_currentIndex];
          } else {
            // Return loading page
            // return Center(
            //   child: SpinKitCubeGrid(
            //     color: Colors.white,
            //     size: 80,
            //   ),
            // );
            return SplashScreen();
          }
        },
      ),
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
    }

    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
