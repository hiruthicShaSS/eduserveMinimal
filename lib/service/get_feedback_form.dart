import 'package:eduserveMinimal/models/feedback_entry.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

Future<List<FeedbackEntry>> getFeedbackForm() async {
  Response page = await get(
    Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
    headers: AuthService.headers,
  );

  Document html = Document.html(page.body);
  List<Element> rows = html
      .querySelectorAll("tr")
      .where((e) => e.className == "rgRow" || e.className == "rgAltRow")
      .toList();

  List<FeedbackEntry> feedbackList = [];
  for (int i = 0; i < rows.length; i++) {
    List<String> rowData = html
        .querySelectorAll("#${rows[i].id} > td")
        .map((e) => e.text.trim())
        .toList();

    String id = Document.html(rows[i].innerHtml)
        .querySelectorAll("input")
        .map((e) => e.id)
        .first;

    feedbackList.add(
      FeedbackEntry(
        hour: rowData[0],
        subject: rowData[1],
        faculty: rowData[2],
        topic: rowData[3],
        rating: 5,
        htmlId: id,
      ),
    );
  }

  return feedbackList;
}
