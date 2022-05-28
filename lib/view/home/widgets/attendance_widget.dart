// 🐦 Flutter imports:
import 'dart:developer';

import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/providers/theme.dart';

class AttendanceContainer extends StatelessWidget {
  const AttendanceContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AppState>(context).user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasError) {
          log("", error: snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return containerWithData(context, snapshot.data!);
        }
        return containerWithData(
            context, User(assemblyAttendance: 0, attendance: 0), true);
      },
    );
  }

  Container containerWithData(BuildContext context, User user,
      [bool isLoading = false]) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeProvider.currentThemeData!.primaryColor.withOpacity(0.1),
        // borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.grey[900]!,
                  child: buildAttendenceContainer(user, context),
                )
              : buildAttendenceContainer(user, context),
        ],
      ),
    );
  }

  Widget buildAttendenceContainer(User user, BuildContext context) {
    final double _height = MediaQuery.of(context).size.height;
    final double _width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                height: _height * 0.15,
                width: _width * 0.45,
                decoration: BoxDecoration(
                  color: ThemeProvider.currentThemeData!.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    AutoSizeText(
                      "Class",
                      minFontSize: 20,
                      maxFontSize: 50,
                    ),
                    Spacer(),
                    AutoSizeText(
                      user.attendance.toString() + "%",
                      minFontSize: 30,
                      maxFontSize: 40,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: (user.attendance ?? 0) < 85,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.warning_amber_outlined, color: Colors.red),
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                height: _height * 0.15,
                width: _width * 0.45,
                decoration: BoxDecoration(
                  color: ThemeProvider.currentThemeData!.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    AutoSizeText(
                      "Assembly",
                      minFontSize: 20,
                      maxFontSize: 50,
                    ),
                    Spacer(),
                    AutoSizeText(
                      user.assemblyAttendance.toString() + "%",
                      minFontSize: 30,
                      maxFontSize: 40,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: (user.assemblyAttendance ?? 0) < 85,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.warning_amber_outlined, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}