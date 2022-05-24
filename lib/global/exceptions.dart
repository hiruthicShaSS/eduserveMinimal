abstract class NoRecordsException implements Exception {
  const NoRecordsException([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class NoRecordsInAttendance extends NoRecordsException {
  const NoRecordsInAttendance([String? messgae]) : super(messgae);
}

class NoRecordsInTimetable extends NoRecordsException {
  const NoRecordsInTimetable([String? messgae]) : super(messgae);
}

class NoRecordsInInternalMarks extends NoRecordsException {
  const NoRecordsInInternalMarks([String? messgae]) : super(messgae);
}
