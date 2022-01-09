import 'package:eduserveMinimal/global/widgets/dot_container.dart';
import 'package:eduserveMinimal/models/attendance_summary.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  AttendanceSummaryWidget({Key? key}) : super(key: key);

  final AttendanceSummary dummyData = AttendanceSummary.generateFakeData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAttendanceSummary(),
      builder: (context, AsyncSnapshot<AttendanceSummary> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            print(snapshot.error);
            print(snapshot);
          }

          return snapshot.hasData
              ? Column(
                  children: [
                    AttendancePieChart(data: snapshot.data!.basicInfo),
                    Padding(padding: EdgeInsets.all(10)),
                    AttendanceBarChart(data: snapshot.data!.summaryData)
                  ],
                )
              : Center(
                  child: Text("Something went wrong while building the chart"));
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.grey[900]!,
          child: Column(
            children: [
              AttendancePieChart(data: dummyData.basicInfo),
              Padding(padding: EdgeInsets.all(10)),
              AttendanceBarChart(data: dummyData.summaryData),
            ],
          ),
        );
      },
    );
  }
}

class AttendancePieChart extends StatelessWidget {
  const AttendancePieChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AttendanceBasicInfo data;

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
                    title: data.presentHours,
                    color: Colors.green,
                    value: double.parse(data.presentHours),
                    radius: 60,
                  ),
                  PieChartSectionData(
                    title: data.absentHours,
                    color: Colors.red,
                    value: double.parse(data.absentHours),
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
                      DotContainer(color: Colors.green, text: "Present"),
                      DotContainer(color: Colors.red, text: "Absent"),
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
                                      Text("Total Hours: ${data.totalHours}"),
                                      Text("Actual: ${data.actual}"),
                                      Text("OD Corrected: ${data.odCorrected}"),
                                      Text("ML Corrected: ${data.mlCorrected}"),
                                      Text("Leave Hours: ${data.leaveHours}"),
                                      Text("Absent Hours: ${data.absentHours}"),
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
  const AttendanceBarChart({Key? key, required this.data}) : super(key: key);

  final List<AttendanceSummaryData> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2),
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Last 7 days attendance/hour",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                buildLegend(),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    maxY: 11,
                    minY: 0,
                    groupsSpace: 15,
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: false,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 2,
                    ),
                    barTouchData: BarTouchData(enabled: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: SideTitles(showTitles: false),
                      rightTitles: SideTitles(showTitles: false),
                      leftTitles: SideTitles(showTitles: false, interval: 1),
                      bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (double index) =>
                              getBottomTitle(data.sublist(0, 7), index),
                          rotateAngle: -45),
                    ),
                    axisTitleData: FlAxisTitleData(
                      show: true,
                      leftTitle: AxisTitle(titleText: "Hour", showTitle: true),
                    ),
                    barGroups: List.generate(7, (index) {
                      List<AttendanceSummaryData> last7Days =
                          data.sublist(0, 7);

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            y: last7Days[index].present,
                            colors: [Colors.green, Colors.greenAccent],
                            backDrawRodData: BackgroundBarChartRodData(
                              colors: [
                                Colors.lightGreenAccent.withOpacity(0.01),
                                Colors.lightGreen.withOpacity(0.01)
                              ],
                              show: true,
                              y: 11,
                            ),
                            width: 15,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                          BarChartRodData(
                            y: last7Days[index].absent,
                            colors: [Colors.red, Colors.redAccent],
                            width: 12,
                            backDrawRodData: BackgroundBarChartRodData(
                              colors: [
                                Colors.redAccent.withOpacity(0.02),
                                Colors.red.withOpacity(0.02)
                              ],
                              show: true,
                              y: 11,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                          BarChartRodData(
                            y: last7Days[index].unAttended,
                            colors: [Colors.black, Colors.grey],
                            backDrawRodData: BackgroundBarChartRodData(
                              colors: [
                                Colors.grey.withOpacity(0.02),
                                Colors.black.withOpacity(0.02)
                              ],
                              show: true,
                              y: 11,
                            ),
                            width: 8,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LinearGradientLegend(
              colors: [Colors.green, Colors.lightGreenAccent],
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Present"),
            )
          ],
        ),
        Row(
          children: [
            _LinearGradientLegend(
              colors: [Colors.red, Colors.redAccent],
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Absent"),
            )
          ],
        ),
        Row(
          children: [
            _LinearGradientLegend(
              colors: [Colors.black, Colors.grey],
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Un-Attended"),
            )
          ],
        ),
      ],
    );
  }
}

String getBottomTitle(List<AttendanceSummaryData> data, index) {
  return data.sublist(data.length - 7)[index.toInt()].date.substring(0, 6);
}

class _LinearGradientLegend extends StatelessWidget {
  _LinearGradientLegend(
      {Key? key, required this.colors, this.height = 10.0, this.width = 20.0})
      : super(key: key);

  final List<Color> colors;
  double height = 10.0;
  double width = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
