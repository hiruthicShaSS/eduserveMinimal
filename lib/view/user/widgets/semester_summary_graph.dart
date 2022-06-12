// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/widgets/dot_container.dart';
import 'package:eduserveMinimal/models/semester_summary_result.dart';

class SemesterSummaryGraph extends StatelessWidget {
  SemesterSummaryGraph({
    Key? key,
    required this.result,
  }) : super(key: key);

  final List<SemesterSummaryResult> result;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Semester Summary", style: TextStyle(fontSize: 25)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DotContainer(color: Colors.red, text: "Arrear"),
              DotContainer(color: Colors.orange, text: "Semester GPA"),
              DotContainer(color: Colors.green, text: "CGPA"),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 10,
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        // rotateAngle: -45,
                        getTitlesWidget: (index, _) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: RotationTransition(
                              turns: const AlwaysStoppedAnimation(-35 / 360),
                              child: Text(DateFormat("MM/yyyy")
                                  .format(result[index.toInt()].monthAndYear)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      gradient: LinearGradient(
                          colors: [Colors.orange, Colors.orangeAccent]),
                      spots: List.generate(
                        result.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          result[index].sgpa,
                        ),
                      ),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      gradient: LinearGradient(
                          colors: [Colors.green, Colors.greenAccent]),
                      spots: List.generate(
                        result.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          result[index].cgpa,
                        ),
                      ),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent]),
                      spots: List.generate(
                        result.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          result[index].arrears.toDouble(),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.redAccent.withOpacity(0.1)
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
