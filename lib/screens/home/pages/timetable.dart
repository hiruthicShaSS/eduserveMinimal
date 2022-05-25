// 🐦 Flutter imports:
import 'dart:developer';

import 'package:eduserveMinimal/models/timetable.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/timetable.dart';
import 'package:lottie/lottie.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class TimeTableView extends StatefulWidget {
  @override
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: FutureBuilder(
            future: getTimetable(),
            builder: (context, AsyncSnapshot<List<TimeTable>> snapshot) {
              if (snapshot.hasError) {
                log("", error: snapshot.error);

                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Text(snapshot.error.toString()),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: Text("Re try"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                List<TimeTable> timeTable = snapshot.data!;
                List<List<TimeTableSubject>> data = [];

                for (var day in timeTable) {
                  data.add([
                    day.hour1,
                    day.hour2,
                    day.hour3,
                    day.hour4,
                    day.hour5,
                    day.hour6,
                    day.hour7,
                    day.hour8,
                    day.hour9,
                    day.hour10,
                    day.hour11,
                  ]);
                }

                return StickyHeadersTable(
                  columnsLength: data.first.length,
                  rowsLength: data.length,
                  columnsTitleBuilder: (i) =>
                      TableCell.stickyRow("Hour ${i + 1}"),
                  rowsTitleBuilder: (i) =>
                      TableCell.stickyColumn(timeTable[i].day),
                  contentCellBuilder: (i, j) => data[j][i].name.isEmpty
                      ? const Placeholder()
                      : TableCell.content(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  data[j][i].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  data[j][i].code,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Batch: ${data[j][i].batch}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      data[j][i].venue,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  cellDimensions: CellDimensions.fixed(
                    stickyLegendWidth: 80,
                    stickyLegendHeight: 80,
                    contentCellWidth: 200,
                    contentCellHeight: 130,
                  ),
                  legendCell: TableCell.legend("Day / Hour"),
                );
              } else {
                return Center(
                    child: Lottie.asset("assets/lottie/timetable.json"));
              }
            },
          ),
        ),
      ),
    );
  }

  String get currentDay {
    switch (DateTime.now().weekday) {
      case 1:
        return "MON";
      case 2:
        return "TUE";
      case 3:
        return "WED";
      case 4:
        return "THU";
      case 5:
        return "FRI";
      default:
        return "";
    }
  }
}

class TableCell extends StatelessWidget {
  TableCell.content({
    this.text,
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 200),
    this.colorBg = Colors.transparent,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _colorHorizontalBorder = Colors.black,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.center,
        _padding = EdgeInsets.zero;

  TableCell.legend(
    this.text, {
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 50),
    this.colorBg = Colors.blueGrey,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _colorHorizontalBorder = Colors.transparent,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.center,
        _padding = EdgeInsets.zero;

  TableCell.stickyRow(
    this.text, {
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 50),
    this.colorBg = Colors.grey,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _colorHorizontalBorder = Colors.black,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.end,
        _padding = EdgeInsets.zero;

  TableCell.stickyColumn(
    this.text, {
    this.child,
    this.textStyle,
    this.cellDimensions = const CellDimensions.uniform(width: 200, height: 200),
    this.colorBg = Colors.grey,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _colorHorizontalBorder = Colors.black,
        _colorVerticalBorder = Colors.black,
        _textAlign = TextAlign.start,
        _padding = EdgeInsets.zero;

  final CellDimensions cellDimensions;

  final String? text;
  final Widget? child;
  final Function()? onTap;

  final double? cellWidth;
  final double? cellHeight;

  final Color colorBg;
  final Color _colorHorizontalBorder;
  final Color _colorVerticalBorder;

  final TextAlign _textAlign;
  final EdgeInsets _padding;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    assert(!(text == null && child == null),
        "Both text and child cannot be null.");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cellWidth,
        height: cellHeight,
        padding: _padding,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: text == null
                    ? child
                    : Text(
                        text!,
                        style: textStyle,
                        maxLines: 2,
                        textAlign: _textAlign,
                      ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: _colorVerticalBorder),
            right: BorderSide(color: _colorHorizontalBorder),
            bottom: BorderSide(color: _colorVerticalBorder),
            left: BorderSide(color: _colorHorizontalBorder),
          ),
          color: colorBg,
        ),
      ),
    );
  }
}
