import 'package:eduserveMinimal/global/widgets/dot_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SemesterSummaryGraph extends StatelessWidget {
  SemesterSummaryGraph({
    Key? key,
    required this.months,
    required this.arrears,
    required this.scgpa,
    required this.cgpa,
  }) : super(key: key);

  final List months;
  final List arrears;
  final List scgpa;
  final List cgpa;

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
              DotContainer(color: Colors.orange, text: "Semester CGPA"),
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
                    rightTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: true, margin: 20),
                    topTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      reservedSize: 30,
                      showTitles: true,
                      rotateAngle: -45,
                      getTitles: (index) {
                        if (index > months.length - 1) return "";
                        return months[index.toInt()];
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      colors: [Colors.orange, Colors.orangeAccent],
                      spots: List.generate(
                        scgpa.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          double.parse(scgpa[index]),
                        ),
                      ),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      colors: [Colors.green, Colors.greenAccent],
                      spots: List.generate(
                        cgpa.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          double.parse(cgpa[index]),
                        ),
                      ),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      colors: [Colors.red, Colors.redAccent],
                      spots: List.generate(
                        arrears.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          double.parse(arrears[index]),
                        ),
                      ),
                      belowBarData: BarAreaData(show: true, colors: [
                        Colors.red.withOpacity(0.1),
                        Colors.redAccent.withOpacity(0.1)
                      ]),
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
