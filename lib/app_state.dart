import 'package:eduserveMinimal/service/scrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  Scraper scraper = Scraper();
  SharedPreferences prefs;

  List attendance = [];
  List<List<String>> leaveInfo = [];

  AppState() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    this.prefs = await SharedPreferences.getInstance();
  }
}
