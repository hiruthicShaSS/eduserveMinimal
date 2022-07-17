// 🎯 Dart imports:
import 'dart:developer' as dev;
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:shimmer/shimmer.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/semester_summary_result.dart';
import 'package:eduserveMinimal/service/semester_summary.dart';
import 'package:eduserveMinimal/view/user/widgets/semester_summary_graph.dart';

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

            if (snapshot.error.runtimeType == NetworkException) {
              return Center(
                  child:
                      Text("$kNoInternetText. Unable to load semester graph."));
            }
          }

          if (snapshot.connectionState == ConnectionState.done) {
            List<SemesterSummaryResult> result = snapshot.data!;

            return SemesterSummaryGraph(result: result);
          }

          List<SemesterSummaryResult> result = List.generate(
            5,
            (index) => SemesterSummaryResult(
              monthAndYear: DateTime(2002, 5, 18),
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
