import 'dart:developer' as dev;
import 'dart:math';

import 'package:eduserveMinimal/models/semester_summary_result.dart';
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
        builder:
            (context, AsyncSnapshot<List<SemesterSummaryResult>> snapshot) {
          if (snapshot.hasError) {
            dev.log("", error: snapshot.error);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            List<SemesterSummaryResult> result = snapshot.data!;

            return SemesterSummaryGraph(result: result);
          }

          List<SemesterSummaryResult> result = List.generate(
            4,
            (index) => SemesterSummaryResult(
              monthAndYear: "",
              arrears: Random().nextInt(10),
              sgpa: Random().nextInt(10).toDouble(),
              cgpa: Random().nextInt(10).toDouble(),
            ),
          );

          return Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.grey[900]!,
            child: SemesterSummaryGraph(result: result),
          );
        });
  }
}
