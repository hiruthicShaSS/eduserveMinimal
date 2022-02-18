// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  static ThemeData? currentThemeData;
  static ThemeMode? currentThemeMode;
  static Brightness? platformBrightness;
  late SharedPreferences prefs;

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    cardColor: Colors.transparent.withOpacity(0.2),
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.dark(secondary: Colors.deepPurpleAccent),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
      ),
    ),
  );
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    cardColor: Colors.transparent.withOpacity(0.2),
    primaryColor: Colors.lightBlueAccent,
    colorScheme: ColorScheme.light(secondary: Colors.blueAccent),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        color: Colors.black,
      ),
    ),
  );

  ThemeProvider() {
    init();
  }

  Future<void> init() async {
    this.prefs = await SharedPreferences.getInstance();
    String? theme = this.prefs.getString("theme");

    if (theme == null)
      this.themeMode = ThemeMode.system;
    else if (theme == "ThemeMode.dark")
      this.themeMode = ThemeMode.dark;
    else if (theme == "ThemeMode.light") this.themeMode = ThemeMode.light;

    currentThemeData = (theme == "ThemeMode.dark" ||
            SchedulerBinding.instance!.window.platformBrightness ==
                Brightness.dark)
        ? dark
        : light;
    platformBrightness = SchedulerBinding.instance!.window.platformBrightness;
    // currentThemeData =
    //     SchedulerBinding.instance!.window.platformBrightness == Brightness.dark
    //         ? dark
    //         : light;
    currentThemeMode = this.themeMode;

    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    currentThemeData = themeMode == ThemeMode.dark ? dark : light;
    currentThemeMode = themeMode;
    notifyListeners();

    this.prefs.setString("theme", themeMode.toString());
  }
}
