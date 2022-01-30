class Leave {
  List<OtherLeave> allLeave = [];
  List<OnDutyLeave> allOnDuty = [];

  void addOtherLeave(List<String> leave) {
    allLeave.add(OtherLeave(
      leaveType: leave[0],
      reason: leave[1],
      fromDate: leave[2],
      fromSession: leave[3],
      toDate: leave[4],
      toSession: leave[5],
      status: leave[6],
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

    List.generate(
            otherLeaveAmount, (index) => ["", "", "", "", "", "", "      "])
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

class OtherLeave {
  String leaveType;
  String reason;
  String fromSession;
  String toSession;
  late String session;
  String fromDate;
  String toDate;
  String status;

  OtherLeave({
    required this.leaveType,
    required this.reason,
    required this.fromSession,
    required this.toSession,
    required this.fromDate,
    required this.toDate,
    required this.status,
  }) {
    if (this.fromSession == this.toSession)
      this.session = fromSession;
    else
      this.session = "${this.fromSession} - ${this.toSession}";
  }
}

class OnDutyLeave {
  String fromDate;
  String fromSession;
  String toDate;
  String toSession;
  late String session;
  String reason;
  String status;
  String pendingWith;
  String createdBy;
  String createdOn;
  String approvalBy;
  String approvalOn;
  String availedBy;
  String availedOn;

  OnDutyLeave({
    required this.fromDate,
    required this.fromSession,
    required this.toDate,
    required this.toSession,
    required this.reason,
    required this.status,
    required this.pendingWith,
    required this.createdBy,
    required this.createdOn,
    required this.approvalBy,
    required this.approvalOn,
    required this.availedBy,
    required this.availedOn,
  }) {
    if (this.fromSession == this.toSession)
      this.session = fromSession;
    else
      this.session = "${this.fromSession} - ${this.toSession}";
  }
}
