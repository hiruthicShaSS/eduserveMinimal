import 'dart:math';

class AttendanceSummary {
  late AttendanceBasicInfo basicInfo;
  List<AttendanceSummaryData> summaryData = [];

  AttendanceSummary(
      {required List basicInfo, required List<List<String>> summaryData}) {
    this.basicInfo = AttendanceBasicInfo(
      semester: basicInfo[0],
      kmail: basicInfo[1],
      phoneNumber: basicInfo[2],
      mentor: basicInfo[3],
      sra: basicInfo[4],
      studentStatus: basicInfo[5],
      totalHours: basicInfo[7],
      presentHours: basicInfo[9],
      actual: basicInfo[10],
      odCorrected: basicInfo[11],
      mlCorrected: basicInfo[12],
      leaveHours: basicInfo[14],
      absentHours: basicInfo[16],
    );

    for (int i = 0; i < summaryData.length; i++)
      this.summaryData.add(AttendanceSummaryData(
            date: summaryData[i][0],
            present: summaryData[i][14],
            absent: summaryData[i][15],
            unAttended: summaryData[i][16],
          ));
  }

  static AttendanceSummary generateFakeData() {
    AttendanceSummary summary = AttendanceSummary(
      basicInfo: [
        "semester",
        "kmail@karunya.edu.in",
        "+91 99999 99999",
        "Jane Doe",
        "Jhon Doe",
        "Unknown",
        "",
        "0",
        "",
        "0",
        "0",
        "0",
        "0",
        "",
        "0",
        "",
        "0",
      ],
      summaryData: List.generate(
          10,
          (index) => List.generate(
              17,
              (index) => index == 0
                  ? "18 MAY 2002"
                  : Random().nextInt(11).toString())),
    );

    return summary;
  }
}

class AttendanceBasicInfo {
  String semester;
  String kmail;
  String phoneNumber;
  String mentor;
  String sra;
  String studentStatus;
  String totalHours;
  String presentHours;
  String actual;
  String odCorrected;
  String mlCorrected;
  String leaveHours;
  String absentHours;

  AttendanceBasicInfo({
    required this.semester,
    required this.kmail,
    required this.phoneNumber,
    required this.mentor,
    required this.sra,
    required this.studentStatus,
    required this.totalHours,
    required this.presentHours,
    required this.actual,
    required this.odCorrected,
    required this.mlCorrected,
    required this.leaveHours,
    required this.absentHours,
  });

  @override
  String toString() {
    return 'AttendanceBasicInfo(semester: $semester, kmail: $kmail, phoneNumber: $phoneNumber, mentor: $mentor, sra: $sra, studentStatus: $studentStatus, totalHours: $totalHours, presentHours: $presentHours, odCorrected: $odCorrected, mlCorrected: $mlCorrected, leaveHours: $leaveHours, absentHours: $absentHours)';
  }
}

class AttendanceSummaryData {
  String date;
  late double present;
  late double absent;
  late double unAttended;

  AttendanceSummaryData({
    required this.date,
    present,
    absent,
    unAttended,
  }) {
    this.present = double.parse(present);
    this.absent = double.parse(absent);
    this.unAttended = double.parse(unAttended);
  }

  @override
  String toString() {
    return 'AttendanceSummaryData(date: $date, present: $present, absent: $absent, unAttended: $unAttended)';
  }
}
