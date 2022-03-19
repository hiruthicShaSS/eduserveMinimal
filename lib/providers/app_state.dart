// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/leave.dart';
import 'package:eduserveMinimal/service/scrap.dart';

class AppState extends ChangeNotifier {
  Scraper scraper = Scraper();
  Map cache = {};

  List? attendance = [];
  Leave? leaveInfo = Leave();

  bool checkedForUpdate = false;

  void refresh() => notifyListeners();
}
