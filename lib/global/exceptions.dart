import 'package:sentry_flutter/sentry_flutter.dart';

class BaseException implements Exception {
  BaseException([this.message]) {
    Sentry.addBreadcrumb(Breadcrumb(message: message, category: "exception"));
  }

  final String? message;

  @override
  String toString() => 'BaseException(message: $message)';
}

class NoRecordsException implements BaseException {
  const NoRecordsException([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class MiscellaneousErrorInEduserve implements BaseException {
  const MiscellaneousErrorInEduserve([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class NoHallTicketAvailable implements BaseException {
  const NoHallTicketAvailable([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class LoginError implements BaseException {
  const LoginError([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class FeedbackFormFound implements BaseException {
  const FeedbackFormFound([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}

class NetworkException implements BaseException {
  NetworkException([this.message, this.actualException]) {
    Sentry.addBreadcrumb(Breadcrumb(message: "Network error"));
  }

  final String? message;
  final Exception? actualException;

  @override
  String toString() {
    return message ?? "No error message provided!";
  }
}
