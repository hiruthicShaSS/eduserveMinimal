// 📦 Package imports:
import 'package:eduserveMinimal/models/leave/on_duty_leave.dart';
import 'package:eduserveMinimal/models/leave/other_leave.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/leave/leave.dart';

Future<Leave> getLeaveInfo() async {
  Map<String, String> headers = AuthService.headers;

  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/Student/Home.aspx"),
    headers: headers,
  );

  if (res.body.contains("User Login")) {
    await AuthService().login();
    headers = AuthService.headers;
  }

  Document html = Document.html(res.body);

  List<OtherLeave> normalLeaves = [];
  List<OnDutyLeave> odLeaves = [];

  for (int i = 0; i < 100; i++) {
    try {
      final leaves = html
          .querySelectorAll("#ctl00_mainContent_grdData_ctl00__$i > td")
          .map((e) => e.innerHtml.trim())
          .toList();

      OtherLeave normalLeave = OtherLeave(
        id: int.tryParse(leaves[0]) ?? 0,
        leaveType: leaves[1],
        reason: leaves[2],
        fromDate: leaves[3],
        toDate: leaves[4],
        fromSession: leaves[5],
        toSession: leaves[6],
        status: leaves[7],
      );

      normalLeaves.add(normalLeave);
    } on RangeError {
      break;
    }
  }

  for (int i = 0; i < 100; i++) {
    try {
      final ods = html
          .querySelectorAll("#ctl00_mainContent_grdStudentOD_ctl00__$i > td")
          .map((e) => e.innerHtml.trim())
          .toList();

      OnDutyLeave onDutyLeave = OnDutyLeave(
        fromDate: ods[0],
        fromSession: ods[1],
        toDate: ods[2],
        toSession: ods[3],
        reason: ods[4],
        status: ods[5],
        pendingWith: ods[6],
        createdBy: ods[7],
        createdOn: ods[8],
        approvalBy: ods[9],
        approvalOn: ods[10],
        availedBy: ods[11],
        availedOn: ods[12],
      );

      odLeaves.add(onDutyLeave);
    } on RangeError {
      break;
    }
  }

  Leave leave = Leave();
  leave.allNormalLeave = normalLeaves;
  leave.allOnDuty = odLeaves;

  return leave;
}
