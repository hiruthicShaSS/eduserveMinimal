// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:eduserveMinimal/service/attendence.dart';

class AttendanceContainer extends StatelessWidget {
  const AttendanceContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAttendance(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Provider.of<AppState>(context, listen: false).attendance =
              snapshot.data;
          return containerWithData(context, snapshot.data!);
        }
        return containerWithData(context, ["0", "0", ""], true);
      },
    );
  }

  Container containerWithData(BuildContext context, List data,
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
                  child: buildAttendenceContainer(data, context),
                )
              : buildAttendenceContainer(data, context),
        ],
      ),
    );
  }

  Widget buildAttendenceContainer(List<dynamic> data, BuildContext context) {
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
                      data[0].toString(),
                      minFontSize: data[1] == "Out-of-rolls" ? 20 : 30,
                      maxFontSize: 40,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: (double.tryParse(data[0].split("%")[0]) ?? 0) < 85,
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
                      data[1].toString(),
                      minFontSize: data[1] == "Out-of-rolls" ? 20 : 30,
                      maxFontSize: 40,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: (double.tryParse(data[1].split("%")[0]) ?? 0) < 85,
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
