// 🎯 Dart imports:
import 'dart:math';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:eduserveMinimal/screens/settings/widgets/user_detail.dart';
import 'package:eduserveMinimal/screens/settings/widgets/user_header.dart';
import 'package:eduserveMinimal/screens/settings/widgets/user_main_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/screens/settings/widgets/semester_summary_graph.dart';
import 'package:eduserveMinimal/service/semester_summary.dart';
import 'package:eduserveMinimal/service/student_info.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getInfo(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map data = snapshot.data!;

            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.0),
                      UserHeader(
                        studentImg: snapshot.data!["studentIMG"],
                        qrCode: snapshot.data!["qrImage"],
                        reg: snapshot.data!["reg"],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              MainContainer(
                                  title: "Arrears",
                                  data: data["arrears"],
                                  color: int.parse(data["arrears"]) > 0
                                      ? Colors.red
                                      : null),
                              MainContainer(title: "CGPA", data: data["cgpa"]),
                              MainContainer(title: "SGPA", data: data["sgpa"]),
                              MainContainer(
                                  title: "CREDITS", data: data["credits"]),
                            ],
                          ),
                        ),
                      ),
                      UserDetailWidget(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['reg'], style: TextStyle(fontSize: 30)),
                            Text(data['name'], style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      UserDetailWidget(
                          child: Text(
                        data['programme'],
                        style: TextStyle(fontSize: 17),
                      )),
                      UserDetailWidget(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['kmail'],
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  data['mobile'],
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "${data["kmail"]}\n${data["mobile"]}"));
                                  Fluttertoast.showToast(
                                      msg: "Copied to clipboard");
                                },
                                icon: Icon(Icons.copy)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 20),
                            child: Text("Misc", style: TextStyle(fontSize: 25)),
                          ),
                          UserDetailWidget(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Non Academic Credits : ${data['nonAcademicCredits']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Mentor : ${data['mentor']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Semester : ${data['semester']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "Above data represented here are result of ${data['resultOf']}",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: FutureBuilder(
                            future: getSemesterSummary(),
                            builder: (context,
                                AsyncSnapshot<Map<String, List<String>>>
                                    snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map data = snapshot.data!;
                                List<String> months = data["months"];
                                List<String> arrears = data["arrears"];
                                List<String> scgpa = data["scgpa"];
                                List<String> cgpa = data["cgpa"];

                                return SemesterSummaryGraph(
                                    months: months,
                                    arrears: arrears,
                                    scgpa: scgpa,
                                    cgpa: cgpa);
                              }

                              return Shimmer.fromColors(
                                baseColor: Colors.grey,
                                highlightColor: Colors.grey[900]!,
                                child: SemesterSummaryGraph(
                                    months: List.generate(
                                        4,
                                        (index) =>
                                            Random().nextInt(12).toString()),
                                    arrears: List.generate(
                                        4,
                                        (index) =>
                                            Random().nextInt(10).toString()),
                                    scgpa: List.generate(
                                        4,
                                        (index) =>
                                            Random().nextInt(10).toString()),
                                    cgpa: List.generate(
                                        4,
                                        (index) =>
                                            Random().nextInt(10).toString())),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
