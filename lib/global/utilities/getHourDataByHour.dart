import 'package:eduserveMinimal/models/timetable_entry.dart';

TimeTableSubject getHourDataByHour(TimeTableEntry timeTableEntry, int hour) {
  return timeTableEntry.toList()[hour];
}
