import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AttendanceSummary extends StatelessWidget {
  const AttendanceSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAttendanceSummary(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              AttendancePieChart(data: snapshot.data),
              Padding(padding: EdgeInsets.all(10)),
              AttendanceBarChart(data: snapshot.data),
            ],
          );
        }
        return LinearProgressIndicator();
      },
    );
  }
}

class AttendancePieChart extends StatelessWidget {
  const AttendancePieChart({
    Key? key,
    this.data,
  }) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 10,
                centerSpaceRadius: 100,
                startDegreeOffset: -45,
                sections: [
                  PieChartSectionData(
                    title: data!["basicInfo"][9],
                    color: Colors.green,
                    value: double.parse(data!["basicInfo"][9]),
                    radius: 60,
                  ),
                  PieChartSectionData(
                    title: data!["basicInfo"].last,
                    color: Colors.red,
                    value: double.parse(data!["basicInfo"].last),
                    radius: 70,
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Present vs Absent Hours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DotContainer(color: Colors.green, text: "Present"),
                      _DotContainer(color: Colors.red, text: "Absent"),
                    ],
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "More",
                      style: TextStyle(
                        color: ThemeProvider.currentThemeData!.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Total Hours: ${data!["basicInfo"][7]}"),
                                      Text("Actual: ${data!["basicInfo"][10]}"),
                                      Text(
                                          "OD Corrected: ${data!["basicInfo"][11]}"),
                                      Text(
                                          "ML Corrected: ${data!["basicInfo"][12]}"),
                                      Text(
                                          "Leave Hours: ${data!["basicInfo"][14]}"),
                                    ],
                                  ),
                                )),
                    ),
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceBarChart extends StatelessWidget {
  const AttendanceBarChart({Key? key, this.data}) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2),
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text("Last 7 days attendance/hour"),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: 11,
                  minY: 0,
                  groupsSpace: 4,
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (double value) =>
                            getBottomTitle(data, value),
                        rotateAngle: -45),
                  ),
                  axisTitleData: FlAxisTitleData(
                    show: true,
                    bottomTitle: AxisTitle(
                        titleText: "Day", showTitle: true, margin: 20),
                    leftTitle: AxisTitle(titleText: "Hour", showTitle: true),
                  ),
                  barGroups: List.generate(
                    data["summaryData"]
                        .sublist(data["summaryData"].length - 7)
                        .length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          y: double.parse(data["summaryData"][index][14]),
                          colors: [Colors.green, Colors.greenAccent],
                          width: 15,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: double.parse(data["summaryData"][index][15]),
                          colors: [Colors.red, Colors.redAccent],
                          width: 15,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: double.parse(data["summaryData"][index][16]),
                          colors: [Colors.grey, Colors.white],
                          width: 10,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

getBottomTitle(data, value) {
  return data["summaryData"]
      .sublist(data["summaryData"].length - 7)[value.toInt()][0]
      .substring(0, 6);
}

class _DotContainer extends StatelessWidget {
  const _DotContainer({Key? key, required this.color, required this.text})
      : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(text),
      ],
    );
  }
}
