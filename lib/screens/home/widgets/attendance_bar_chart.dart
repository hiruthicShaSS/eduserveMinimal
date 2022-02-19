// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fl_chart/fl_chart.dart';

class AttendanceBarChart extends StatelessWidget {
  AttendanceBarChart({Key? key, required this.data}) : super(key: key);

  final List<List<String>> data;
  final List<Color> _presentGradient = [Colors.green, Colors.greenAccent];
  final List<Color> _absentGradient = [Colors.red, Colors.redAccent];
  final List<Color> _unAttendedGradient = [Colors.grey, Colors.white];

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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Last 7 days attendance/hour",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      LineChartLegend(
                          text: "Present", gradientColors: _presentGradient),
                      LineChartLegend(
                          text: "Absent", gradientColors: _absentGradient),
                      LineChartLegend(
                          text: "Un-attended",
                          gradientColors: _unAttendedGradient),
                    ],
                  ),
                ),
              ],
            ),
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
                          colors: _presentGradient,
                          width: 15,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: double.parse(data[index][15]),
                          backDrawRodData: BackgroundBarChartRodData(
                            colors: _absentGradient.reversed
                                .map((color) => color.withOpacity(0.01))
                                .toList(),
                            show: true,
                          ),
                          colors: _absentGradient,
                          width: 12,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          y: double.parse(data[index][16]),
                          backDrawRodData: BackgroundBarChartRodData(
                            colors: _unAttendedGradient.reversed
                                .map((color) => color.withOpacity(0.01))
                                .toList(),
                            show: true,
                          ),
                          colors: _unAttendedGradient,
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

class LineChartLegend extends StatelessWidget {
  const LineChartLegend({
    Key? key,
    required this.text,
    required this.gradientColors,
  }) : super(key: key);

  final String text;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
