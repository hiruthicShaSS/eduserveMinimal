import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'eduserveMinimal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.dark(),
      ),
      home: MyHomePage(title: "eduserveMinimal"),
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
  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.more_horiz_outlined),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildAttendenceContainer(_width, _height),
            SizedBox(height: 10.0),
            buildStudentInfoContainer(),
            SizedBox(height: 10.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                    left: _width / 30, right: _width / 30, top: _height / 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black12,
                ),
                child: ListView(
                  children: [
                    Center(child: Text("Leave Application's", style: TextStyle(fontSize: 20, color: Colors.purple[400]),)),
                    SizedBox(height: 20.0),
                    ListTile(
                      title: Text("List item Active"),
                      tileColor: Colors.green,
                    ),
                    SizedBox(height: 5.0),
                    ListTile(
                      title: Text("List item Pending"),
                      tileColor: Colors.orange,
                    ),
                    SizedBox(height: 5.0),
                    ListTile(
                      title: Text("List item Rejected"),
                      tileColor: Colors.red,
                    ),
                    SizedBox(height: 5.0),
                    ListTile(
                      title: Text("List item Rejected"),
                      tileColor: Colors.red,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          print(index);
        },
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
      ),
    );
  }

  Container buildStudentInfoContainer() {
    return Container(
      // Basic student info
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Current Semester: ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Text(
                "4th",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Arrear's: ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Text(
                "5",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ML Corrected: ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Text(
                "98.0",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OD Corrected: ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Text(
                "97.0",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildAttendenceContainer(double width, double height) {
    return Container(
      // Attendance Details
      color: Colors.black87,
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            // Class Attendence box
            padding: EdgeInsets.only(left: width / 20, top: height / 30),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white24,
                ),
                width: width / 2.5,
                height: height / 8,
                child: Column(
                  children: [
                    Text(
                      "Class Attendance",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w800),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 35.0),
                      child: Row(
                        children: [
                          Text(
                            "98.0",
                            style: TextStyle(
                                fontSize: 30.0, color: Colors.green[300]),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                              child: Text(
                                "/100",
                                style: TextStyle(fontSize: 15.0),
                              ))
                        ],
                      ),
                    ),
                  ],
                )),
          ),
          Padding(
            // Assembly Attendence box
            padding: EdgeInsets.only(left: width / 10, top: height / 30),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white24,
                ),
                width: width / 2.5,
                height: height / 8,
                child: Column(
                  children: [
                    Text(
                      "Assembly Attendance",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w800),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 35.0),
                      child: Row(
                        children: [
                          Text(
                            "45",
                            style: TextStyle(fontSize: 15.0, color: Colors.red),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                              child: Text(
                                "/100",
                                style: TextStyle(fontSize: 30.0),
                              ))
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
