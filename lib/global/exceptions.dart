class NoRecordsException implements Exception {
  const NoRecordsException([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class MiscellaneousErrorInEduserve implements Exception {
  const MiscellaneousErrorInEduserve([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class NoHallTicketAvailable implements Exception {
  const NoHallTicketAvailable([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class LoginError implements Exception {
  const LoginError([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class FeedbackFormFound implements Exception {
  const FeedbackFormFound([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}
