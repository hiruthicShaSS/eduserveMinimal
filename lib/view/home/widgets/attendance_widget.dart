// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:eduserveMinimal/service/check_for_attendance_change.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/providers/app_state.dart';

class AttendanceContainer extends StatelessWidget {
  const AttendanceContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AppState>(context).getUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasError) {
          log("Error fetching attendance data: ", error: snapshot.error);

          if (snapshot.error.runtimeType == NetworkException) {
            return Center(child: Text(kNoInternetText));
          }
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return containerWithData(context, snapshot.data!);
        }

        return containerWithData(
            context,
            User(
              arrears: 0,
              assemblyAttendance: 10,
              attendance: 10,
              cgpa: 0,
              credits: 0,
              kmail: "",
              mentor: "",
              mobile: "",
              name: "",
              nonAcademicCredits: 0,
              programme: "",
              registerNumber: "",
              resultOf: "",
              semester: 0,
              sgpa: 0,
            ),
            true);
      },
    );
  }

  Widget containerWithData(BuildContext context, User user,
      [bool isLoading = false]) {
    return Column(
      children: [
        isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey,
                highlightColor: Colors.grey[900]!,
                child: buildAttendenceContainer(user, context),
              )
            : buildAttendenceContainer(user, context),
      ],
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
                  color: Theme.of(context).colorScheme.onBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    AutoSizeText(
                      "Class",
                      minFontSize: 20,
                      maxFontSize: 50,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          user.attendance.toString() + "%",
                          minFontSize: 30,
                          maxFontSize: 40,
                        ),
                        _AttendanceChangeIcon(attendance: user.attendance),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: user.attendance < 85,
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
                  color: Theme.of(context).colorScheme.onBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    AutoSizeText(
                      "Assembly",
                      minFontSize: 20,
                      maxFontSize: 50,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          user.assemblyAttendance.toString() + "%",
                          minFontSize: 30,
                          maxFontSize: 40,
                        ),
                        _AttendanceChangeIcon(
                          attendance: user.assemblyAttendance,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: user.assemblyAttendance < 85,
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

class _AttendanceChangeIcon extends StatelessWidget {
  const _AttendanceChangeIcon({Key? key, required this.attendance})
      : super(key: key);

  final double attendance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkForAttendanceChange(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) return SizedBox();

          Map<String, double> data =
              Map<String, double>.from(snapshot.data! as Map);

          return attendance == data["att"]!
              ? const SizedBox()
              : attendance > data["att"]!
                  ? const Icon(Icons.arrow_upward, color: Colors.white)
                  : const Icon(Icons.arrow_downward, color: Colors.white);
        }

        return const SizedBox();
      },
    );
  }
}
