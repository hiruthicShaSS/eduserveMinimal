import 'package:flutter/material.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:eduserveMinimal/view/misc/widgets/table_cell.dart' as tableCell;

import '../../../models/timetable_entry.dart';

class TimetableWidget extends StatelessWidget {
  const TimetableWidget({
    Key? key,
    required this.data,
    required this.timeTable,
    required this.weekdays,
  }) : super(key: key);

  final List<List<TimeTableSubject>> data;
  final List<TimeTableEntry> timeTable;
  final List<String> weekdays;

  @override
  Widget build(BuildContext context) {
    return StickyHeadersTable(
      columnsLength: data.first.length,
      rowsLength: data.length,
      columnsTitleBuilder: (i) =>
          tableCell.TableCell.stickyRow("Hour ${i + 1}"),
      rowsTitleBuilder: (i) => tableCell.TableCell.stickyColumn(
        text: timeTable[i].day,
        colorBg: weekdays.indexOf(timeTable[i].day.toLowerCase()) + 1 ==
                DateTime.now().weekday
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : Colors.transparent,
      ),
      contentCellBuilder: (i, j) => data[j][i].name.isEmpty
          ? const Placeholder()
          : tableCell.TableCell.content(
              colorBg: weekdays.indexOf(timeTable[j].day.toLowerCase()) + 1 ==
                      DateTime.now().weekday
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data[j][i].name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data[j][i].code,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 30,
                      children: [
                        Text(
                          "Batch: ${data[j][i].batch}",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          data[j][i].venue,
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      cellDimensions: CellDimensions.fixed(
        stickyLegendWidth: 80,
        stickyLegendHeight: 40,
        contentCellWidth: 200,
        contentCellHeight: 140,
      ),
      legendCell: tableCell.TableCell.legend("Day / Hour"),
    );
  }
}
