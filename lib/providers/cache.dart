// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/internal_mark.dart';
import 'package:eduserveMinimal/service/internal_marks.dart';

class CacheProvider extends ChangeNotifier {
  InternalMarksService _internalMarksService = InternalMarksService();
  Map<int, List<InternalMark>> _internalMarks = {};
  List<String>? _internalAcademicTerms;

  Future<List<String>> getInternalAcademicTerms() async {
    if (_internalAcademicTerms != null) {
      return _internalAcademicTerms!;
    }

    _internalAcademicTerms =
        await _internalMarksService.getInternalAcademicTerms();

    return _internalAcademicTerms!;
  }

  Future<List<InternalMark>> getInternalMarkOf(int academicTerm) async {
    if (_internalMarks.containsKey(academicTerm)) {
      return _internalMarks[academicTerm]!;
    }

    _internalMarks[academicTerm] =
        await _internalMarksService.getInternalMarks(academicTerm);

    return _internalMarks[academicTerm]!;
  }
}
