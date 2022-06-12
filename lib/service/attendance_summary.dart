// 📦 Package imports:
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/attendance/attendance.dart';
import 'package:eduserveMinimal/models/attendance/attendance_summary.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/network_service.dart';

Future<SemesterAttendance> getAttendanceSummary([retries = 0]) async {
  NetworkService _networkService = NetworkService();

  Map<String, String> headers = AuthService.headers;
  Map formData = AuthService.formData;
  formData.remove("ctl00\$mainContent\$DDLEXAM");

  headers["referer"] = "https://eduserve.karunya.edu/Student/AttSummary.aspx";
  Response res = await _networkService.get(
    Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
    headers: headers,
  );

  Document html = Document.html(res.body);

  List<String> academicTerms = html
      .querySelectorAll("#mainContent_DDLACADEMICTERM > option")
      .map((node) => node.innerHtml.trim())
      .toList();

  int maxAcademicTerm = academicTerms.length -
      1; // -1 for for compensating 0 indexing and to remove the option 'Select the Academic Term'

  List inputs = html
      .querySelectorAll("input")
      .map((e) => {e.attributes["name"]: e.attributes["value"]})
      .toList();

  inputs.removeWhere(
      (element) => element.keys.first == null || element.values.first == null);

  for (var input in inputs) {
    formData[input.keys.first!] = input.values.first;
  }

  formData["ctl00\$mainContent\$DDLACADEMICTERM"] = maxAcademicTerm.toString();
  res = await _networkService.post(
    Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
    headers: headers,
    body: formData,
  );

  if (res.body.contains("No records to display.")) {
    throw NoRecordsException("No attendance records to display.");
  }

  html = Document.html(res.body);
  List<Attendance> allAttendance = [];

  for (int i = 0; i < 100; i++) {
    try {
      final attendanceData = html
          .querySelectorAll("#ctl00_mainContent_grdData_ctl00__$i > td")
          .map((e) => e.innerHtml.trim())
          .toList();

      if (attendanceData.isEmpty) break;

      int totalPresent = attendanceData.where((e) => e == "P").toList().length;
      int totalAbsent = attendanceData.where((e) => e == "A").toList().length;
      int totalUnAttended =
          attendanceData.where((e) => e == "U").toList().length;

      AttendanceSummary attendanceSummary = AttendanceSummary(
        totalAttended: totalPresent,
        totalAbsent: totalAbsent,
        totalUnAttended: totalUnAttended,
      );

      Attendance attendance = Attendance(
        date: DateFormat("dd MMM yyyy").parse(attendanceData[0]),
        assemblyAttended:
            Attendance.getAttendanceTypeFromString(attendanceData[1]),
        hour0: Attendance.getAttendanceTypeFromString(attendanceData[2]),
        hour1: Attendance.getAttendanceTypeFromString(attendanceData[3]),
        hour2: Attendance.getAttendanceTypeFromString(attendanceData[4]),
        hour3: Attendance.getAttendanceTypeFromString(attendanceData[5]),
        hour4: Attendance.getAttendanceTypeFromString(attendanceData[6]),
        hour5: Attendance.getAttendanceTypeFromString(attendanceData[7]),
        hour6: Attendance.getAttendanceTypeFromString(attendanceData[8]),
        hour7: Attendance.getAttendanceTypeFromString(attendanceData[9]),
        hour8: Attendance.getAttendanceTypeFromString(attendanceData[10]),
        hour9: Attendance.getAttendanceTypeFromString(attendanceData[11]),
        hour10: Attendance.getAttendanceTypeFromString(attendanceData[12]),
        hour11: Attendance.getAttendanceTypeFromString(attendanceData[13]),
        summary: attendanceSummary,
      );

      allAttendance.add(attendance);
    } on RangeError {
      break;
    }
  }

  SemesterAttendance semesterAttendance = SemesterAttendance(
    attendance: allAttendance,
    totalHours: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLTOTALDAYS")
            ?.innerHtml
            .trim() ??
        "0"),
    presentHours: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLPRESENT")
            ?.innerHtml
            .trim() ??
        "0"),
    actual: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLACTUAL")
            ?.innerHtml
            .trim() ??
        "0"),
    odCorrected: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLOD")
            ?.innerHtml
            .trim() ??
        "0"),
    mlCorrected: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLML")
            ?.innerHtml
            .trim() ??
        "0"),
    leaveHours: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLLEAVE")
            ?.innerHtml
            .trim() ??
        "0"),
    absentHours: double.parse(html
            .querySelector("#mainContent_UCStudentAttendance_LBLABSENT")
            ?.innerHtml
            .trim() ??
        "0"),
  );

  return semesterAttendance;
}
