// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class CustomTheme {
  List themes = ["dark", "light"];
  String theme = "dark";
  SharedPreferences prefs;

  static var bg = Colors.grey;
  static var appBarBG = Colors.black;
  static var navBarBG = Colors.black;
  static var shadowColor = Colors.white;
  static var iconColor = Colors.white;
  static var text = Colors.white;
  static var importantText = Colors.amber;
  static List<MaterialColor> applicationStatusColors = [
    Colors.green,
    Colors.red,
    Colors.orange
  ];

  Future<void> applyTheme(String theme) async {
    if (theme == "dark") {
      bg = Colors.grey;
      appBarBG = Colors.black;
      navBarBG = Colors.black;
      shadowColor = Colors.white;
      iconColor = Colors.white;
      text = Colors.white;
      importantText = Colors.amber;
      applicationStatusColors = [Colors.green, Colors.red, Colors.orange];
    } else if (theme == "light") {
      bg = Colors.white;
      appBarBG = Colors.white70;
      navBarBG = Colors.white70;
      shadowColor = Colors.black;
      iconColor = Colors.black;
      text = Colors.black;
      importantText = Colors.orange;
      applicationStatusColors = [Colors.green, Colors.red, Colors.orange];
    }
  }

  Future<void> setTheme(String theme) async {
    prefs.setString("theme", theme);
    applyTheme(theme);
  }

  Future<List> getTheme() async {
    prefs = await SharedPreferences.getInstance();
    return [await prefs.getString("theme"), themes];
  }
}
