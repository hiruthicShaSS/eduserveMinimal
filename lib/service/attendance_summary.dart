import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/class_attendance.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';

Future<SemesterAttendance> getAttendanceSummary([retries = 0]) async {
  Map<String, String> headers = httpHeaders;
  Map formData = httpFormData;
  formData.remove("ctl00\$mainContent\$DDLEXAM");

  headers["referer"] = "https://eduserve.karunya.edu/Student/AttSummary.aspx";
  Response res = await get(
      Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
      headers: headers);

  var soup = Beautifulsoup(res.body);
  final inputs = soup.find_all("input").map((e) => e.attributes).toList();

  final academicTerms =
      soup.find_all("option").map((e) => e.text.trim()).toSet().toList();
  int maxAcademicTerm = academicTerms.length -
      1; // -1 for for compensating 0 indexing and to remove the option 'Select the Academic Term'

  inputs.forEach((element) {
    // Populate form data
    if (formData[element["name"]] == "") {
      formData[element["name"]] =
          (element["value"] == "Clear" || element["value"] == null)
              ? ""
              : element["value"];
    }
  });

  formData["ctl00\$mainContent\$DDLACADEMICTERM"] = maxAcademicTerm.toString();
  res = await post(
      Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
      headers: headers,
      body: formData);

  if (res.body.contains("No records to display.")) {
    throw NoRecordsInAttendance("No attendance records to display.");
  }

  Document html = Document.html(res.body);
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
        assemblyAttended: attendanceData[1] == "P",
        hour0: attendanceData[2] == "P",
        hour1: attendanceData[3] == "P",
        hour2: attendanceData[4] == "P",
        hour3: attendanceData[5] == "P",
        hour4: attendanceData[6] == "P",
        hour5: attendanceData[7] == "P",
        hour6: attendanceData[8] == "P",
        hour7: attendanceData[9] == "P",
        hour8: attendanceData[10] == "P",
        hour9: attendanceData[11] == "P",
        hour10: attendanceData[12] == "P",
        hour11: attendanceData[13] == "P",
        attendanceSummary: attendanceSummary,
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
