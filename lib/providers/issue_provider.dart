// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/enum.dart';

class IssueProvider extends ChangeNotifier {
  Set<Issue> _issues = Set();

  List<Issue> get issues => _issues.toList();

  int get length => _issues.length;

  bool get isEmpty => _issues.isEmpty;

  bool get isNotEmpty => _issues.isNotEmpty;

  bool contains(Issue issue) => _issues.contains(issue);

  void add(Issue issue) {
    _issues.add(issue);

    notifyListeners();
  }

  void remove(Issue issue) {
    _issues.remove(issue);

    notifyListeners();
  }

  void clear() {
    _issues.clear();

    notifyListeners();
  }
}
