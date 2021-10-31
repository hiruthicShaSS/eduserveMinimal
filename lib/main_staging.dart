import 'package:eduserveMinimal/edu_serve.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppState>(create: (_) => AppState()),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ], child: const EduServeMinimal(flavor: "staging")));
}
