import 'dart:math';
import 'package:eduserveMinimal/screens/home/widgets/attendance_bar_chart.dart';
import 'package:eduserveMinimal/screens/home/widgets/attendance_pie_chart.dart';
import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  AttendanceSummaryWidget({Key? key}) : super(key: key);

  final Map dummyData = {
    "basicInfo": [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      Random().nextInt(90).toString(),
      Random().nextInt(10).toString()
    ],
    "summaryData": List.generate(
        7,
        (index) => List.generate(
            17,
            (index) =>
                index == 0 ? "18 MAY 2002" : Random().nextInt(11).toString()))
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAttendanceSummary(),
      builder: (context, AsyncSnapshot<Map<String, List>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            print(snapshot.error);
            print(snapshot);
          }

          if (snapshot.hasData) {
            List<String> basicInfo =
                List<String>.from(snapshot.data!["basicInfo"]!);
            List<List<String>> summaryData =
                List<List<String>>.from(snapshot.data!["summaryData"]!);
            summaryData = summaryData.length < 7
                ? summaryData
                : summaryData.sublist(0, 7);

            return Column(
              children: [
                AttendancePieChart(data: basicInfo),
                Padding(padding: EdgeInsets.all(10)),
                AttendanceBarChart(data: summaryData)
              ],
            );
          } else {
            Center(
                child: Text("Something went wrong while building the chart"));
          }
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.grey[900]!,
          child: Column(
            children: [
              AttendancePieChart(data: dummyData["basicInfo"]),
              Padding(padding: EdgeInsets.all(10)),
              AttendanceBarChart(data: dummyData["summaryData"]),
            ],
          ),
        );
      },
    );
  }
}
