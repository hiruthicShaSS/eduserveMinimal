// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppState>(create: (_) => AppState()),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ], child: EduServeMinimal(flavor: "development")));
}
