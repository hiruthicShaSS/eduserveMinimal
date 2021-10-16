// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/views/feedback_form.dart';
import 'package:eduserveMinimal/views/home_page.dart';
import 'package:eduserveMinimal/views/timetable.dart';

void main(List<String> args) {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>(create: (_) => AppState()),
    ],
    child: MaterialApp(
      home: EduServeMinimal(),
      routes: {
        "/feedbackForm": (BuildContext context) => FeedbackForm(),
        "/timetable": (BuildContext context) => TimeTable(),
        "/home": (BuildContext context) => HomePage(),
      },
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
    ),
  ));
}
