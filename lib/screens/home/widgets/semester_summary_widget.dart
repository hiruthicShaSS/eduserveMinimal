import 'dart:math';

import 'package:eduserveMinimal/screens/settings/widgets/semester_summary_graph.dart';
import 'package:eduserveMinimal/service/semester_summary.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SemesterSummaryWidget extends StatelessWidget {
  const SemesterSummaryWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSemesterSummary(),
        builder: (context, AsyncSnapshot<Map<String, List<String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map data = snapshot.data!;
            List<String> months = data["months"];
            List<String> arrears = data["arrears"];
            List<String> scgpa = data["scgpa"];
            List<String> cgpa = data["cgpa"];

            return SemesterSummaryGraph(
                months: months, arrears: arrears, scgpa: scgpa, cgpa: cgpa);
          }

          return Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.grey[900]!,
            child: SemesterSummaryGraph(
                months: List.generate(
                    4, (index) => Random().nextInt(12).toString()),
                arrears: List.generate(
                    4, (index) => Random().nextInt(10).toString()),
                scgpa: List.generate(
                    4, (index) => Random().nextInt(10).toString()),
                cgpa: List.generate(
                    4, (index) => Random().nextInt(10).toString())),
          );
        });
  }
}
