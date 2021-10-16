// Flutter imports:
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';

class AttendanceContainer extends StatelessWidget {
  const AttendanceContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height = MediaQuery.of(context).size.height;
    final double _width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future:
          Provider.of<AppState>(context, listen: false).scraper.getAttendance(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Provider.of<AppState>(context, listen: false).attendance =
              snapshot.data;
          return containerWithData(_height, _width, snapshot.data!);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Container containerWithData(double _height, double _width, List data) {
    return Container(
      decoration: BoxDecoration(
        color: (ThemeProvider.platformBrightness == Brightness.dark
                ? Colors.deepPurple
                : Colors.blue)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Attendance",
            style: TextStyle(fontSize: 30),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
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
                            minFontSize: 30,
                            maxFontSize: 40,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: double.parse(data[0].split("%")[0]) < 85,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.warning_amber_outlined,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
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
                            minFontSize: 30,
                            maxFontSize: 40,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: double.parse(data[1].split("%")[0]) < 85,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.warning_amber_outlined,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
