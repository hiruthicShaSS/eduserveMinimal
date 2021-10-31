// Flutter imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/screens/home/pages/pages.dart';

class EduServeMinimal extends StatelessWidget {
  const EduServeMinimal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context)..initPlatformState();

    return MaterialApp(
      home: HomePage(),
      routes: {
        "/feedbackForm": (BuildContext context) => FeedbackForm(),
        "/timetable": (BuildContext context) => TimeTable(),
        "/home": (BuildContext context) => HomePage(),
      },
      darkTheme: ThemeProvider.dark,
      title: "eduserveMinimal",
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
    );
  }
}
