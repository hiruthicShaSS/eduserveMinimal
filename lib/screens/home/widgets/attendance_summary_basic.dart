// 🎯 Dart imports:
import 'dart:developer' as dev;
import 'dart:math';

// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/class_attendance.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 📦 Package imports:
import 'package:shimmer/shimmer.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/screens/home/widgets/attendance_bar_chart.dart';
import 'package:eduserveMinimal/screens/home/widgets/attendance_pie_chart.dart';

class AttendanceSummaryView extends StatelessWidget {
  AttendanceSummaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AppState>(context).getAttendance,
      builder: (context, AsyncSnapshot<SemesterAttendance> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            if (snapshot.error.runtimeType == NoRecordsException) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    snapshot.error.toString(),
                  ),
                ),
              );
            }

            dev.log("Error: ", error: snapshot.error);
          }

          if (snapshot.hasData) {
            if (snapshot.data!.attendance.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(child: Text("No records found!")),
              );
            }

            return Column(
              children: [
                AttendancePieChart(semesterAttendance: snapshot.data!),
                Padding(padding: EdgeInsets.all(10)),
                AttendanceBarChart(semesterAttendance: snapshot.data!)
              ],
            );
          } else {
            return const Center(
                child: Text("Something went wrong while building the chart"));
          }
        }

        SemesterAttendance semesterAttendance = SemesterAttendance(
          absentHours: Random().nextInt(10).toDouble(),
          actual: 0,
          attendance: List.generate(
            7,
            (index) => Attendance(
              date: DateTime(2002, 5, 18),
              assemblyAttended: Random().nextBool(),
              hour0: Random().nextBool(),
              hour1: Random().nextBool(),
              hour2: Random().nextBool(),
              hour3: Random().nextBool(),
              hour4: Random().nextBool(),
              hour5: Random().nextBool(),
              hour6: Random().nextBool(),
              hour7: Random().nextBool(),
              hour8: Random().nextBool(),
              hour9: Random().nextBool(),
              hour10: Random().nextBool(),
              hour11: Random().nextBool(),
              attendanceSummary: AttendanceSummary(
                totalAbsent: Random().nextInt(2),
                totalAttended: Random().nextInt(8),
                totalUnAttended: Random().nextInt(1),
              ),
            ),
          ),
          leaveHours: 0,
          mlCorrected: 0,
          odCorrected: 0,
          presentHours: Random().nextInt(90).toDouble(),
          totalHours: 0,
        );

        return Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.grey[900]!,
          child: Column(
            children: [
              AttendancePieChart(semesterAttendance: semesterAttendance),
              Padding(padding: EdgeInsets.all(10)),
              AttendanceBarChart(semesterAttendance: semesterAttendance),
            ],
          ),
        );
      },
    );
  }
}
