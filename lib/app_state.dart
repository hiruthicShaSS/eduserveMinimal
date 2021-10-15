// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/service/scrap.dart';

class AppState extends ChangeNotifier {
  Scraper scraper = Scraper();
  SharedPreferences prefs;

  List attendance = [];
  Map leaveInfo = {};

  AppState() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    this.prefs = await SharedPreferences.getInstance();
  }
}
