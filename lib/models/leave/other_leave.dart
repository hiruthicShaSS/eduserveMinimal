class OtherLeave {
  int id;
  String leaveType;
  String reason;
  String fromDate;
  String toDate;
  String fromSession;
  String toSession;
  late String session;
  String status;

  OtherLeave({
    required this.id,
    required this.leaveType,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.fromSession,
    required this.toSession,
    required this.status,
  }) {
    if (this.fromSession == this.toSession)
      this.session = fromSession;
    else
      this.session = "${this.fromSession} - ${this.toSession}";
  }

  @override
  String toString() {
    return 'OtherLeave(id: $id, leaveType: $leaveType, reason: $reason, fromDate: $fromDate, toDate: $toDate, fromSession: $fromSession, toSession: $toSession, session: $session, status: $status)';
  }
}
