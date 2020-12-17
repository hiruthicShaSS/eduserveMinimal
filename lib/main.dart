import 'package:eduserveMinimal/service/getData.dart';
import 'package:eduserveMinimal/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:hexcolor/hexcolor.dart';

import 'package:eduserveMinimal/home.dart';
import 'package:eduserveMinimal/user.dart';

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
    ),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    Home(),
    User(),
  ];

  List<Widget> appBarActions = [];

  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      HexColor("#833ab4"),
      HexColor("#fd1d1d"),
      HexColor("#fcb045")
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  Map cloudData = new Map();
  Future<Map> downloadData() async {
    Services services = new Services();
    Map data = await services.getDataFromCloud();
    cloudData = data;
    return data;
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
        future: downloadData(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Home.cloudData = cloudData;
            return _children[_currentIndex];
          } else {
            return Center(
              child: SpinKitCubeGrid(
                color: Colors.white,
                size: 80,
              ),
            );
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
    if (index == 1) {
      // user Page
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

    setState(() {
      _currentIndex = index;
    });
  }
}
