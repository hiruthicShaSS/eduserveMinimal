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

  List feedback = [];
  List allFeedback = [];
  bool feedbackStart = false;
  feedbackList.forEach((element) {
    if (element == "Class Not Handled") {
      feedback.removeWhere((element) => element == "");
      allFeedback.add(feedback);
      feedbackStart = false;
      feedback = [];

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
