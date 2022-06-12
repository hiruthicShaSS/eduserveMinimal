// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/enum.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  ThemeData _currentThemeData =
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark
          ? dark
          : light;
  AppTheme currentAppTheme = AppTheme.system;

  late SharedPreferences prefs;

  static ThemeData dark = ThemeData.dark().copyWith(
    primaryColor: Colors.deepPurpleAccent,
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.greenAccent,
          onPrimary: const Color.fromARGB(255, 255, 255, 255),
          onSecondary: const Color.fromARGB(255, 255, 255, 255),
          onBackground: Colors.deepPurpleAccent,
        ),
    brightness: Brightness.dark,
    dividerColor: Colors.white54,
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
        letterSpacing: 1,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
        letterSpacing: 1,
      ),
    ),
  );

  static ThemeData light = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: Colors.lightBlueAccent,
    colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          onBackground: Colors.tealAccent.withOpacity(0.4),
          surface: Colors.grey,
        ),
    primaryTextTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        color: Colors.black,
      ),
    ),
  );

  static ThemeData valorant = ThemeData(
    primarySwatch: generateMaterialColor(Color.fromRGBO(255, 129, 137, 1)),
    primaryColor: const Color.fromRGBO(255, 70, 84, 1),
    scaffoldBackgroundColor: const Color(0xFF1C252E),
    colorScheme: ColorScheme(
      background: const Color(0xFF1C252E),
      primary: const Color.fromRGBO(255, 70, 84, 1),
      secondary: const Color.fromRGBO(13, 23, 33, 1),
      surface: const Color(0xFFb96a46),
      error: Color.fromARGB(255, 10, 2, 2),
      onPrimary: const Color.fromARGB(255, 255, 255, 255),
      onSecondary: const Color.fromARGB(255, 255, 255, 255),
      onBackground: const Color.fromARGB(255, 21, 33, 44),
      onError: const Color(0xFF790202),
      onSurface: const Color(0xFF1e1412),
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    backgroundColor: const Color.fromRGBO(13, 23, 33, 1),
    dividerColor: Colors.white54,
    fontFamily: "Valorant",
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
        letterSpacing: 1,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
        letterSpacing: 1,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 23, 40, 56),
      foregroundColor: const Color(0xFFff4457),
      titleTextStyle: TextStyle(
        color: const Color.fromRGBO(255, 70, 84, 1),
        fontFamily: "Valorant",
      ),
    ),
  );

  ThemeProvider() {
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString("theme");

    if (theme != null) {
      switch (theme) {
        case "AppTheme.system":
          themeMode = ThemeMode.system;
          _currentThemeData =
              SchedulerBinding.instance.window.platformBrightness ==
                      Brightness.dark
                  ? dark
                  : light;
          currentAppTheme = AppTheme.system;
          break;
        case "AppTheme.dark":
          themeMode = ThemeMode.dark;
          _currentThemeData = dark;
          currentAppTheme = AppTheme.dark;
          break;
        case "AppTheme.light":
          themeMode = ThemeMode.light;
          _currentThemeData = light;
          currentAppTheme = AppTheme.light;
          break;
        case "AppTheme.valorant":
          themeMode = ThemeMode.dark;
          _currentThemeData = valorant;
          currentAppTheme = AppTheme.valorant;
          break;
      }
    }

    notifyListeners();
  }

  ThemeData get currentThemeData => _currentThemeData;
  ThemeData get getDarkTheme =>
      currentAppTheme == AppTheme.valorant ? valorant : dark;

  Future<void> applyTheme(AppTheme appTheme) async {
    prefs.setString("theme", appTheme.toString());

    switch (appTheme) {
      case AppTheme.system:
        themeMode = ThemeMode.system;
        _currentThemeData =
            SchedulerBinding.instance.window.platformBrightness ==
                    Brightness.dark
                ? dark
                : light;
        currentAppTheme = AppTheme.system;
        break;
      case AppTheme.light:
        themeMode = ThemeMode.light;
        _currentThemeData = light;
        currentAppTheme = AppTheme.light;
        break;
      case AppTheme.dark:
        themeMode = ThemeMode.dark;
        _currentThemeData = dark;
        currentAppTheme = AppTheme.dark;
        break;
      case AppTheme.valorant:
        themeMode = ThemeMode.dark;
        _currentThemeData = valorant;
        currentAppTheme = AppTheme.valorant;
        break;
    }

    notifyListeners();
  }
}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.5),
    100: tintColor(color, 0.4),
    200: tintColor(color, 0.3),
    300: tintColor(color, 0.2),
    400: tintColor(color, 0.1),
    500: tintColor(color, 0),
    600: tintColor(color, -0.1),
    700: tintColor(color, -0.2),
    800: tintColor(color, -0.3),
    900: tintColor(color, -0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);
