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
