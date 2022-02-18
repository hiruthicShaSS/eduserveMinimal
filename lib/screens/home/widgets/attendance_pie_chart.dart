import 'package:eduserveMinimal/global/widgets/dot_container.dart';
import 'package:eduserveMinimal/providers/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AttendancePieChart extends StatelessWidget {
  const AttendancePieChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 10,
                centerSpaceRadius: 100,
                startDegreeOffset: -45,
                sections: [
                  PieChartSectionData(
                    title: data[9],
                    color: Colors.green,
                    value: double.tryParse(data[9]) ?? 0,
                    radius: 60,
                  ),
                  PieChartSectionData(
                    title: data.last,
                    color: Colors.red,
                    value: double.tryParse(data.last) ?? 0,
                    radius: 70,
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Present vs Absent Hours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DotContainer(color: Colors.green, text: "Present"),
                      DotContainer(color: Colors.red, text: "Absent"),
                    ],
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "More",
                      style: TextStyle(
                        color: ThemeProvider.currentThemeData!.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Total Hours: ${data[7]}"),
                                      Text("Actual: ${data[10]}"),
                                      Text("OD Corrected: ${data[11]}"),
                                      Text("ML Corrected: ${data[12]}"),
                                      Text("Leave Hours: ${data[14]}"),
                                    ],
                                  ),
                                )),
                    ),
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
