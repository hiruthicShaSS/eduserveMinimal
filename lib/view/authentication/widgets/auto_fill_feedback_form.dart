// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/fill_feedback_form.dart';
import 'package:eduserveMinimal/service/get_feedback_form.dart';

class AutoFillFeedback extends StatelessWidget {
  const AutoFillFeedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: autoFill(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Future.delayed(
                Duration.zero, () => Navigator.of(context).pushNamed("/home"));
            return SizedBox();
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/lottie/submitting_feedback.json"),
                Text("Sit tight, we are submitting your feedback form!"),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> autoFill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt("autoFillFeedbackValue") != null) {
      Map feedbackRating = {};
      List feedbackForm = await getFeedbackForm();

      for (final feedback in feedbackForm) {
        feedbackRating[feedback.last] = prefs.getInt("autoFillFeedbackValue");
      }

      bool feedBackFormFilled = await fillFeedbackForm(feedbackRating);

      if (feedBackFormFilled) return true;
    }

    return false;
  }
}
