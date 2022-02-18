// 📦 Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';

Future<List> getFeedbackForm() async {
  Map<String, String> headers = httpHeaders;

  Response page = await get(
      Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
      headers: headers);

  Beautifulsoup feedbackSoup = Beautifulsoup(page.body);
  List feedbackList =
      feedbackSoup.find_all("td").map((e) => e.text.trim()).toList();

  List feedback_inputs = feedbackSoup
      .find_all("input")
      .map((e) => e.id)
      .where((id) => id.contains("ClientState") && id.length > 36)
      .toList();

  List feedback = [];
  List allFeedback = [];

  int counter = 0;
  feedbackList.forEach((element) {
    if (element == "Class Not Handled") {
      feedback.add(feedback_inputs[counter]);
      feedback.removeWhere((element) => element == "");

      allFeedback.add(feedback);
      feedback = [];
      counter++;

      return;
    }

    if (element.toString().contains("Command item")) {
      return;
    }

    feedback.add(element.toString().trim());
  });

  return allFeedback;
}
