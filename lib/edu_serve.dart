// Flutter imports:
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/views/feedback_form.dart';
import 'package:eduserveMinimal/views/home_page.dart';
import 'package:eduserveMinimal/views/timetable.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:provider/provider.dart';

class EduServeMinimal extends StatelessWidget {
  const EduServeMinimal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: {
        "/feedbackForm": (BuildContext context) => FeedbackForm(),
        "/timetable": (BuildContext context) => TimeTable(),
        "/home": (BuildContext context) => HomePage(),
      },
      darkTheme: ThemeProvider.dark,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
    );
  }
}
