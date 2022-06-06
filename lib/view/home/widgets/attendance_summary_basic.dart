// 🎯 Dart imports:
import 'dart:developer' as dev;
import 'dart:math';

// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/models/attendance/attendance.dart';
import 'package:eduserveMinimal/models/attendance/attendance_summary.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/issue_provider.dart';
import 'package:eduserveMinimal/service/check_absent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 📦 Package imports:
import 'package:shimmer/shimmer.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/view/home/widgets/attendance_bar_chart.dart';
import 'package:eduserveMinimal/view/home/widgets/attendance_pie_chart.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  AttendanceSummaryWidget({Key? key}) : super(key: key);

  bool alreadyIssueReported = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2(
        builder: (context, AppState appState, IssueProvider issueProvider, _) {
      return FutureBuilder(
        future: appState.attendance,
        builder: (context, AsyncSnapshot<SemesterAttendance> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              dev.log("Error: ", error: snapshot.error);

              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(child: Text(snapshot.error.toString())),
              );
            }

            if (snapshot.hasData) {
              if (snapshot.data!.attendance.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(child: Text("No data available")),
                );
              }

              if (!alreadyIssueReported) {
                checkForAbsent(
                  semesterAttendance: snapshot.data,
                  context: context,
                  showNotification: false,
                ).then((isAbsentYesterday) {
                  alreadyIssueReported = true;

                  if (isAbsentYesterday) {
                    issueProvider.add(Issue.abesnt_yesterday);
                  }
                });
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
                assemblyAttended: AttendanceType.present,
                hour0: AttendanceType.present,
                hour1: AttendanceType.absent,
                hour2: AttendanceType.unattended,
                hour3: AttendanceType.present,
                hour4: AttendanceType.absent,
                hour5: AttendanceType.present,
                hour6: AttendanceType.present,
                hour7: AttendanceType.present,
                hour8: AttendanceType.unattended,
                hour9: AttendanceType.present,
                hour10: AttendanceType.absent,
                hour11: AttendanceType.present,
                summary: AttendanceSummary(
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
    });
  }
}
