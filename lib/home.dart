import 'package:flutter/material.dart';

import 'package:eduserveMinimal/service/getData.dart';

class Home extends StatefulWidget {
  static Map cloudData;
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // static Services services = new Services();
  Map cloudData = Home.cloudData; // services.getData();

  // void updateData() async {
  //   if (cloudData["downloaded"] != true) {
  //     cloudData = await services.getDataFromCloud();
  //     Home.cloudData = cloudData;
  //     setState(() {});
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   updateData();
  // }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Column(
        children: [
          buildAttendenceContainer(_width, _height),
          SizedBox(height: 10.0),
          buildStudentInfoContainer(),
          SizedBox(height: 10.0),
          buildApplicationsExpanded(_width, _height)
        ],
      ),
    );
  }

  Expanded buildApplicationsExpanded(double _width, double _height) {
    List parseApplications() {
      Map data = cloudData["leaveApplications"];
      List returnData = new List();

      data.forEach((key, value) {
        try {
          returnData.add({
            "title": key,
            "type": value[0],
            "date": value[2],
            "dayOff": value[3],
            "status": (value[6] == "Rejected")
                ? 3
                : (value[6] == "Active")
                    ? 1
                    : 2
          });
        } catch (e) {}
      });

      return returnData;
    }

    List data = parseApplications();

    return Expanded(
      child: Container(
          padding: EdgeInsets.only(
              left: _width / 30, right: _width / 30, top: _height / 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black12,
          ),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(height: 5.0),
                  ListTile(
                    title: Text(data[index]["title"]),
                    leading: (data[index]["dayOff"] == "Full Day")
                        ? Icon(Icons.star)
                        : (data[index]["dayOff"] == "Half Day")
                            ? Icon(Icons.star_half)
                            : null,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(data[index]["date"]),
                        Text(
                          data[index]["type"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    tileColor: (data[index]["status"] == 1)
                        ? Colors.green
                        : (data[index]["status"] == 2)
                            ? Colors.orange
                            : Colors.red,
                  ),
                ],
              );
            },
          )),
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
                cloudData["semester"],
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
                cloudData["arrears"],
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
    List safeNumbersStyle = [
      TextStyle(fontSize: 30.0, color: Colors.green[300]),
      TextStyle(fontSize: 15.0)
    ];
    List unsafeNumbersStyle = [
      TextStyle(fontSize: 15.0, color: Colors.black),
      TextStyle(fontSize: 30.0),
    ];
    Color classAttendenceBoxColor = Colors.white24;
    Color assemblyAttendenceBoxColor = Colors.white24;

    String classAttStatus = "";
    String asmAttStatus = "";
    try {
      if (double.parse(cloudData["att"]) < 85.0) {
        classAttendenceBoxColor = Colors.amber[900];
      }
      if (double.parse(cloudData["asm"]) < 85.0) {
        assemblyAttendenceBoxColor = Colors.amber[900];
      }
    } on Exception catch (e) {
      classAttStatus = cloudData["att"];
      asmAttStatus = cloudData["asm"];

      cloudData["att"] = "0.0";
      cloudData["asm"] = "0.0";
    }

    return Container(
      // Attendance Details
      padding: EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.white24, spreadRadius: 3)
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            // Class Attendence box
            padding: EdgeInsets.only(left: width / 20, top: height / 30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: classAttendenceBoxColor,
              ),
              width: width / 2.5,
              height: height / 8,
              child: Column(
                children: [
                  Text(
                    "Class Attendance",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 35.0),
                    child: Row(
                      children: [
                        Text(cloudData["att"].toString(),
                            style: (double.parse(cloudData["att"]) > 85.0)
                                ? safeNumbersStyle[0]
                                : unsafeNumbersStyle[0]),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                            child: Text("/100",
                                style: (double.parse(cloudData["att"]) > 85.0)
                                    ? safeNumbersStyle[1]
                                    : unsafeNumbersStyle[1]))
                      ],
                    ),
                  ),
                  Text(
                      (classAttStatus == "Out-of-rolls") ? classAttStatus : ""),
                ],
              ),
            ),
          ),
          Padding(
            // Assembly Attendence box
            padding: EdgeInsets.only(left: width / 10, top: height / 30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: assemblyAttendenceBoxColor,
              ),
              width: width / 2.5,
              height: height / 8,
              child: Column(
                children: [
                  Text(
                    "Assembly Attendance",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 35.0),
                    child: Row(
                      children: [
                        Text(cloudData["asm"].toString(),
                            style: (double.parse(cloudData["asm"]) > 85.0)
                                ? safeNumbersStyle[0]
                                : unsafeNumbersStyle[0]),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                            child: Text("/100",
                                style: (double.parse(cloudData["asm"]) > 85.0)
                                    ? safeNumbersStyle[1]
                                    : unsafeNumbersStyle[1]))
                      ],
                    ),
                  ),
                  Text((asmAttStatus == "Out-of-rolls") ? asmAttStatus : ""),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
