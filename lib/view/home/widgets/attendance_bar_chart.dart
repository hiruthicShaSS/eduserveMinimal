// 🐦 Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:eduserveMinimal/models/attendance/attendance.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/view/home/semester_attendance_view.dart';
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
    List<Attendance> attendance = semesterAttendance.attendance.sublist(
        0,
        semesterAttendance.attendance.length >= 7
            ? 7
            : semesterAttendance.attendance.length);

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
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, _) => Text(
                          DateFormat("dd MMM")
                              .format(attendance[value.toInt()].date),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    attendance.sublist(0, 7).length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: attendance[index]
                              .summary
                              .totalAttended
                              .toDouble(),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: _presentGradient,
                          ),
                          width: 15,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          toY: attendance[index].summary.totalAbsent.toDouble(),
                          backDrawRodData: BackgroundBarChartRodData(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: _absentGradient.reversed
                                  .map((color) => color.withOpacity(0.01))
                                  .toList(),
                            ),
                            show: true,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: _absentGradient,
                          ),
                          width: 12,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          toY: attendance[index]
                              .summary
                              .totalUnAttended
                              .toDouble(),
                          backDrawRodData: BackgroundBarChartRodData(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: _unAttendedGradient.reversed
                                  .map((color) => color.withOpacity(0.01))
                                  .toList(),
                            ),
                            show: true,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: _unAttendedGradient,
                          ),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  "More",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SemesterAttendanceView(),
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
        AutoSizeText(
          text,
          minFontSize: 8,
          maxFontSize: 10,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 8),
        ),
      ],
    );
  }
}
