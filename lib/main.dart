// Flutter imports:
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';
import 'package:eduserveMinimal/edu_serve.dart';

void main(List<String> args) async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>(create: (_) => AppState()),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ],
    child: EduServeMinimal(),
  ));
}
