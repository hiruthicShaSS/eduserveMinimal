// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/screens/home/pages/pages.dart';

class EduServeMinimal extends StatelessWidget {
  const EduServeMinimal({Key? key, this.flavor = "production"})
      : super(key: key);
  final String flavor;

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context)..initPlatformState();

    return MaterialApp(
      debugShowCheckedModeBanner: flavor == "development",
      home: HomePage(),
      routes: {
        "/feedbackForm": (BuildContext context) => FeedbackForm(),
        "/timetable": (BuildContext context) => TimeTable(),
        "/home": (BuildContext context) => HomePage(),
        "/credentials": (BuildContext context) => Credentials(),
      },
      darkTheme: ThemeProvider.dark,
      title: "eduserveMinimal",
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
    );
  }
}
