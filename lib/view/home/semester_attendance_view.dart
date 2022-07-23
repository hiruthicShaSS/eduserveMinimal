// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/models/attendance/attendance.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/view/misc/widgets/table_cell.dart' as tableCell;

class SemesterAttendanceView extends StatelessWidget {
  const SemesterAttendanceView({Key? key, this.yesterday}) : super(key: key);

  final DateTime? yesterday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer(builder: (context, AppState appState, _) {
          return FutureBuilder(
            future: appState.getAttendance(),
            builder: (BuildContext context,
                AsyncSnapshot<SemesterAttendance> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  List<Attendance> allAttendance = snapshot.data!.attendance;

                  List<List<AttendanceType>> data = [];

                  for (var attendance in allAttendance) {
                    data.add([
                      attendance.assemblyAttended,
                      attendance.hour0,
                      attendance.hour1,
                      attendance.hour2,
                      attendance.hour3,
                      attendance.hour4,
                      attendance.hour5,
                      attendance.hour6,
                      attendance.hour7,
                      attendance.hour8,
                      attendance.hour9,
                      attendance.hour10,
                      attendance.hour11,
                    ]);
                  }

                  return StickyHeadersTable(
                    columnsLength: 13,
                    rowsLength: allAttendance.length,
                    columnsTitleBuilder: (i) => tableCell.TableCell.stickyRow(
                      i == 0 ? "Assembly" : "Hour ${i - 1}",
                    ),
                    rowsTitleBuilder: (i) => tableCell.TableCell.stickyColumn(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: allAttendance[i].date == yesterday
                              ? Colors.red
                              : Colors.transparent,
                          width: 2,
                        )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat("dd MMM yyyy")
                                .format(allAttendance[i].date)),
                            if (data[i].contains(AttendanceType.absent))
                              Expanded(
                                child: Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    contentCellBuilder: (i, j) {
                      String text =
                          Attendance.getStringFromAttendanceType(data[j][i]);

                      print(data[j][i]);

                      return tableCell.TableCell.content(
                        text: text,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(DateFormat("dd MMM yyyy")
                                  .format(allAttendance[j].date)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Attended: " +
                                      allAttendance[j]
                                          .summary
                                          .totalAttended
                                          .toString()),
                                  Text("Absent: " +
                                      allAttendance[j]
                                          .summary
                                          .totalAbsent
                                          .toString()),
                                  Text("Unattended: " +
                                      allAttendance[j]
                                          .summary
                                          .totalUnAttended
                                          .toString()),
                                ],
                              ),
                            ),
                          );
                        },
                        colorBg: text == "A"
                            ? Colors.red
                            : text == "U"
                                ? Colors.white.withOpacity(0.2)
                                : (text == "-" || text == "")
                                    ? Colors.transparent
                                    : Colors.green.withOpacity(0.4),
                      );
                    },
                    cellDimensions: CellDimensions.fixed(
                      stickyLegendWidth: 110,
                      stickyLegendHeight: 40,
                      contentCellWidth: 80,
                      contentCellHeight: 40,
                    ),
                  );
                }

                return const Center(child: Text("No data availbale!"));
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        }),
      ),
    );
  }
}
