// 🐦 Flutter imports:
import 'package:eduserveMinimal/models/class_attendance.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fl_chart/fl_chart.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/widgets/dot_container.dart';
import 'package:eduserveMinimal/providers/theme.dart';

class AttendancePieChart extends StatelessWidget {
  const AttendancePieChart({Key? key, required this.semesterAttendance})
      : super(key: key);

  final SemesterAttendance semesterAttendance;

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
                    title: semesterAttendance.presentHours.toString(),
                    color: Colors.green,
                    value: semesterAttendance.actual,
                    radius: 60,
                  ),
                  PieChartSectionData(
                    title: semesterAttendance.absentHours.toString(),
                    color: Colors.red,
                    value: semesterAttendance.absentHours,
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
                    text: TextSpan(
                      children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Total Hours: ${semesterAttendance.totalHours}"),
                                        Text(
                                            "Actual: ${semesterAttendance.actual}"),
                                        Text(
                                            "OD Corrected: ${semesterAttendance.odCorrected}"),
                                        Text(
                                            "ML Corrected: ${semesterAttendance.mlCorrected}"),
                                        Text(
                                            "Leave Hours: ${semesterAttendance.leaveHours}"),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
