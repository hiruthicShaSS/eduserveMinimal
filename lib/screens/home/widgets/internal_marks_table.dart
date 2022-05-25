import 'dart:developer';

import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/internal_mark.dart';
import 'package:eduserveMinimal/providers/cache.dart';
import 'package:eduserveMinimal/service/internal_marks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    "Subject Code",
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

            return RotatedBox(
              quarterTurns: 1,
              child: Container(
                margin: EdgeInsets.only(top: 2, left: 5, right: 5),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.white70),
                          dividerThickness: 2,
                          columns: List.generate(
                            tableheader.length,
                            (index) => DataColumn(
                              label: Text(
                                tableheader[index].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          rows: List.generate(
                            internalMarks.length,
                            (index) {
                              bool fail = internalMarks[index].marksScored < 20;
                              bool fullMark =
                                  internalMarks[index].marksScored >=
                                      internalMarks[index].totalMarks;

                              return DataRow(
                                color: MaterialStateProperty.all(
                                  fail
                                      ? failedRowColor
                                      : fullMark
                                          ? fullMarksRowColor
                                          : null,
                                ),
                                cells: [
                                  DataCell(
                                    Text(internalMarks[index].subjectCode),
                                  ),
                                  DataCell(
                                    Text(internalMarks[index].subjectName),
                                  ),
                                  DataCell(
                                    Text(internalMarks[index].iaParameter),
                                  ),
                                  DataCell(
                                    Text(internalMarks[index]
                                        .totalMarks
                                        .toString()),
                                  ),
                                  DataCell(
                                    Container(
                                      color:
                                          internalMarks[index].marksScored < 20
                                              ? Colors.red.withOpacity(0.8)
                                              : null,
                                      child: Text(internalMarks[index]
                                          .marksScored
                                          .toString()),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      color: internalMarks[index].testMarks < 20
                                          ? Colors.red.withOpacity(0.8)
                                          : null,
                                      child: Text(internalMarks[index]
                                          .testMarks
                                          .toString()),
                                    ),
                                  ),
                                  DataCell(
                                    Text(internalMarks[index]
                                        .onlineExamMarks
                                        .toString()),
                                  ),
                                  DataCell(
                                    Text(internalMarks[index].attendance),
                                  ),
                                  DataCell(
                                    Text(DateFormat("dd MMM yyyy")
                                        .format(internalMarks[index].testDate)),
                                  ),
                                  DataCell(
                                    Text(internalMarks[index].markEnteredBy),
                                  ),
                                  DataCell(
                                    Text(DateFormat("dd/MM/yyyy hh:mm:ss aa")
                                        .format(internalMarks[index]
                                            .markEnteredOn)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }
}
