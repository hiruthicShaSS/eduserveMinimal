// 🌎 Project imports:
import 'package:eduserveMinimal/models/leave/on_duty_leave.dart';
import 'package:eduserveMinimal/models/leave/other_leave.dart';

class Leave {
  List<OtherLeave> allNormalLeave = [];
  List<OnDutyLeave> allOnDuty = [];

  void addOtherLeave(List<String> leave) {
    allNormalLeave.add(OtherLeave(
      id: int.tryParse(leave[0]) ?? 0,
      leaveType: leave[1],
      reason: leave[2],
      fromDate: leave[3],
      toDate: leave[4],
      fromSession: leave[5],
      toSession: leave[6],
      status: leave[7],
    ));
  }

  void addOnDuty(List<String> leave) {
    allOnDuty.add(OnDutyLeave(
      fromDate: leave[0],
      fromSession: leave[1],
      toDate: leave[2],
      toSession: leave[3],
      reason: leave[4],
      status: leave[5],
      pendingWith: leave[6],
      createdBy: leave[7],
      createdOn: leave[8],
      approvalBy: leave[9],
      approvalOn: leave[9],
      availedBy: leave[10],
      availedOn: leave[11],
    ));
  }

  static Leave generateFakeLeave([otherLeaveAmount = 3, onDutyAmount = 2]) {
    Leave leave = Leave();

    List.generate(otherLeaveAmount,
            (index) => ["-1", "", "", "", "", "", "", "      "])
        .forEach((element) => leave.addOtherLeave(element));

    List.generate(
        onDutyAmount,
        (index) => [
              "           ",
              "        ",
              "           ",
              "           ",
              "                    ",
              "           ",
              "",
              "",
              "",
              "",
              "",
              "",
              ""
            ]).forEach((element) => leave.addOtherLeave(element));

    return leave;
  }
}
