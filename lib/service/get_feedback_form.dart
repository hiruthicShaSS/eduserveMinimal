// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';

Future<List> getFeedbackForm([int? stars]) async {
  Map<String, String> headers = httpHeaders;

  Response page = await get(
      Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
      headers: headers);

  Beautifulsoup feedbackSoup = Beautifulsoup(page.body);
  List feedbackList =
      feedbackSoup.find_all("td").map((e) => e.text.trim()).toList();

  RegExp FEEDBACK_INPUT_EXP =
      RegExp("ctl00_mainContent_grdHFB_ctl00_ctl\d{2}_rtngHFB_ClientState");
  // List feedback_inputs = feedbackSoup
  //     .find_all("input")
  //     .where((e) => FEEDBACK_INPUT_EXP.hasMatch(e.id))
  //     .toList();

  List feedback_inputs = feedbackSoup
      .find_all("input")
      .map((e) => e.id)
      .where((id) => id.contains("ClientState") && id.length > 36)
      .toList();

  List feedback = [];
  List allFeedback = [];
  bool feedbackStart = false;

  int counter = 0;
  feedbackList.forEach((element) {
    if (element == "Class Not Handled") {
      feedback.add(feedback_inputs[counter]);
      feedback.removeWhere((element) => element == "");

      allFeedback.add(feedback);
      feedbackStart = false;
      feedback = [];
      counter++;

      return;
    }

    if (element.toString().contains("Command item")) {
      feedbackStart = true;
      return;
    }

    feedback.add(element.toString().trim());
  });

  return allFeedback;
}
