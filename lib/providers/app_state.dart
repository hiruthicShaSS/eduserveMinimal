// Flutter imports:
import 'package:eduserveMinimal/models/leave.dart';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/service/scrap.dart';

class AppState extends ChangeNotifier {
  Scraper scraper = Scraper();
  static SharedPreferences? prefs;
  Map cache = {};

  List? attendance = [];
  Leave? leaveInfo = Leave();

  AppState() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    prefs = await SharedPreferences.getInstance();
  }
}
