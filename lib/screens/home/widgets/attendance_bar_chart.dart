// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fl_chart/fl_chart.dart';

class AttendanceBarChart extends StatelessWidget {
  const AttendanceBarChart({Key? key, required this.data}) : super(key: key);

  final List<List<String>> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2),
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text("Last 7 days attendance/hour"),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: 11,
                  minY: 0,
                  groupsSpace: 10,
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (double value) =>
                          data[value.toInt()][0].substring(0, 6),
                      rotateAngle: -55,
                      getTextStyles: (context, _) => TextStyle(fontSize: 12),
                    ),
                  ),
                  axisTitleData: FlAxisTitleData(
                    show: true,
                    bottomTitle: AxisTitle(
                        titleText: "Day", showTitle: true, margin: 20),
                    leftTitle: AxisTitle(titleText: "Hour", showTitle: true),
                  ),
                  barGroups: List.generate(
                    data.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          y: double.parse(data[index][14]),
                          colors: [Colors.green, Colors.greenAccent],
                          width: 15,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: double.parse(data[index][15]),
                          backDrawRodData: BackgroundBarChartRodData(
                            colors: [
                              Colors.redAccent.withOpacity(0.01),
                              Colors.red.withOpacity(0.01)
                            ],
                            show: true,
                          ),
                          colors: [Colors.red, Colors.redAccent],
                          width: 12,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: double.parse(data[index][16]),
                          backDrawRodData: BackgroundBarChartRodData(
                            colors: [
                              Colors.white.withOpacity(0.01),
                              Colors.grey.withOpacity(0.01)
                            ],
                            show: true,
                          ),
                          colors: [Colors.grey, Colors.white],
                          width: 10,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
