// 🌎 Project imports:
import 'package:eduserveMinimal/models/hallticket/subject.dart';

class HallTicket {
  bool attendanceEligibility;
  bool feesEligibility;
  bool examEligibility;
  String? reason;
  List<Subject> subjects = [];

  HallTicket({
    required this.attendanceEligibility,
    required this.feesEligibility,
    required this.examEligibility,
    this.reason,
    required this.subjects,
  });

  bool get isEligibile =>
      attendanceEligibility && feesEligibility && examEligibility;

  bool get isSubjectsEligibile =>
      subjects.where((subject) => subject.eligible).length == subjects.length;

  @override
  String toString() {
    return 'HallTicket(attendanceEligibility: $attendanceEligibility, feesEligibility: $feesEligibility, examEligibility: $examEligibility, reason: $reason, subjects: $subjects)';
  }
}
