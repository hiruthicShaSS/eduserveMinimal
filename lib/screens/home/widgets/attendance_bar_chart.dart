// 🐦 Flutter imports:
import 'package:eduserveMinimal/models/class_attendance.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AttendanceBarChart extends StatelessWidget {
  const AttendanceBarChart({Key? key, required this.semesterAttendance})
      : super(key: key);

  final SemesterAttendance semesterAttendance;
  final List<Color> _presentGradient = const [Colors.green, Colors.greenAccent];
  final List<Color> _absentGradient = const [Colors.red, Colors.redAccent];
  final List<Color> _unAttendedGradient = const [Colors.grey, Colors.white];

  @override
  Widget build(BuildContext context) {
    List<Attendance> attendance = semesterAttendance.attendance.sublist(0, 7);

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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Last 7 days attendance/hour",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      LineChartLegend(
                          text: "Present", gradientColors: _presentGradient),
                      LineChartLegend(
                          text: "Absent", gradientColors: _absentGradient),
                      LineChartLegend(
                          text: "Un-attended",
                          gradientColors: _unAttendedGradient),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: 11,
                  minY: 0,
                  groupsSpace: 10,
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (double value) => DateFormat("dd MMM")
                          .format(attendance[value.toInt()].date),
                      rotateAngle: -55,
                      getTextStyles: (context, _) => TextStyle(fontSize: 12),
                    ),
                  ),
                  axisTitleData: FlAxisTitleData(
                    show: true,
                    bottomTitle: AxisTitle(
                        titleText: "Day", showTitle: true, margin: 20),
                    leftTitle: AxisTitle(
                      titleText: "Hour",
                      showTitle: true,
                      margin: 20,
                    ),
                  ),
                  barGroups: List.generate(
                    attendance.sublist(0, 7).length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          y: attendance[index]
                              .attendanceSummary
                              .totalAttended
                              .toDouble(),
                          colors: _presentGradient,
                          width: 15,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: attendance[index]
                              .attendanceSummary
                              .totalAbsent
                              .toDouble(),
                          backDrawRodData: BackgroundBarChartRodData(
                            colors: _absentGradient.reversed
                                .map((color) => color.withOpacity(0.01))
                                .toList(),
                            show: true,
                          ),
                          colors: _absentGradient,
                          width: 12,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: attendance[index]
                              .attendanceSummary
                              .totalUnAttended
                              .toDouble(),
                          backDrawRodData: BackgroundBarChartRodData(
                            colors: _unAttendedGradient.reversed
                                .map((color) => color.withOpacity(0.01))
                                .toList(),
                            show: true,
                          ),
                          colors: _unAttendedGradient,
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

class LineChartLegend extends StatelessWidget {
  const LineChartLegend({
    Key? key,
    required this.text,
    required this.gradientColors,
  }) : super(key: key);

  final String text;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
