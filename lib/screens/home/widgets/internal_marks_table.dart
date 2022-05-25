import 'dart:developer';
import 'dart:ui';

import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/internal_mark.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/service/internal_marks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:eduserveMinimal/screens/home/widgets/table_cell.dart'
    as tableCell;

class InternalMarksTable extends StatefulWidget {
  const InternalMarksTable({
    Key? key,
    required this.academicTerm,
  }) : super(key: key);

  final int academicTerm;

  @override
  State<InternalMarksTable> createState() => _InternalMarksTableState();
}

class _InternalMarksTableState extends State<InternalMarksTable> {
  InternalMarksService internalMarksService = InternalMarksService();

  List tableheader = [
    "Subject Name",
    "IA Parameter",
    "Total Marks",
    "Marks Scored",
    "Test Marks",
    "Online Exam Marks",
    "Attendance",
    "Test Date",
    "Entered by",
    "Entered on"
  ];

  Color failedRowColor = Colors.red.withOpacity(0.2);
  Color fullMarksRowColor = Colors.green.withOpacity(0.2);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, CacheProvider cacheProvider, _) {
      return FutureBuilder(
        future: Provider.of<CacheProvider>(context)
            .getInternalMarkOf(widget.academicTerm),
        builder: (context, AsyncSnapshot<List<InternalMark>> snapshot) {
          if (snapshot.hasError) {
            log("", error: snapshot.error);

            if (snapshot.error.runtimeType == NoRecordsException) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final List<InternalMark> internalMarks = snapshot.data!;
            List<List> data = [];

            for (var exam in internalMarks) {
              data.add([
                exam.subjectName,
                exam.iaParameter,
                exam.totalMarks,
                exam.marksScored,
                exam.testMarks,
                exam.onlineExamMarks,
                exam.attendance,
                DateFormat("yyyy-MM-dd").format(exam.testDate),
                exam.markEnteredBy,
                DateFormat("yyyy-MM-dd hh:mm:ss").format(exam.markEnteredOn),
              ]);
            }

            return Container(
              margin: EdgeInsets.only(top: 2, left: 5, right: 5),
              child: StickyHeadersTable(
                columnsLength: data.first.length,
                rowsLength: internalMarks.length,
                columnsTitleBuilder: (i) =>
                    tableCell.TableCell.stickyRow(tableheader[i]),
                rowsTitleBuilder: (i) => tableCell.TableCell.content(
                  text: internalMarks[i].subjectCode,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  colorBg: internalMarks[i].marksScored < 20
                      ? Colors.red.withOpacity(0.2)
                      : internalMarks[i].marksScored >=
                              internalMarks[i].totalMarks
                          ? Colors.green.withOpacity(0.2)
                          : Colors.transparent,
                ),
                contentCellBuilder: (i, j) => tableCell.TableCell.content(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      data[j][i].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: internalMarks[j].marksScored == data[j][i]
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ),
                  colorBg: internalMarks[j].marksScored < 20
                      ? Colors.red.withOpacity(0.2)
                      : internalMarks[j].marksScored >=
                              internalMarks[j].totalMarks
                          ? Colors.green.withOpacity(0.2)
                          : Colors.transparent,
                ),
                onContentCellPressed: (i, j) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(internalMarks[j].subjectName),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            internalMarks[j].marksScored.toString(),
                            style: TextStyle(
                              fontSize: 80,
                              color: internalMarks[j].marksScored < 20
                                  ? Colors.red
                                  : internalMarks[j].marksScored >=
                                          internalMarks[j].totalMarks
                                      ? Colors.green
                                      : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Divider(thickness: 5, color: Colors.white),
                          ),
                          Text(
                            internalMarks[j].totalMarks.toString(),
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (internalMarks[j].marksScored.toInt() == 69) {
                    Fluttertoast.showToast(msg: "Nice... 😏");
                  }
                },
                cellDimensions: CellDimensions.fixed(
                  stickyLegendWidth: 80,
                  stickyLegendHeight: 80,
                  contentCellWidth: 150,
                  contentCellHeight: 100,
                ),
                legendCell: tableCell.TableCell.legend("Subject Code"),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }
}
