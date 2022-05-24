class InternalMark {
  String subjectCode;
  String subjectName;
  String iaParameter;
  int totalMarks;
  double marksScored;
  double testMarks;
  double onlineExamMarks;
  String attendance;
  DateTime testDate;
  String markEnteredBy;
  DateTime markEnteredOn;

  InternalMark({
    required this.subjectCode,
    required this.subjectName,
    required this.iaParameter,
    required this.totalMarks,
    required this.marksScored,
    required this.testMarks,
    required this.onlineExamMarks,
    required this.attendance,
    required this.testDate,
    required this.markEnteredBy,
    required this.markEnteredOn,
  });
}
