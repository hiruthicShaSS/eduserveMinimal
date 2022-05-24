// 📦 Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/models/semester_summary_result.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';

Future<List<SemesterSummaryResult>> getSemesterSummary() async {
  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/Student/SemSummary.aspx"),
    headers: AuthService.headers,
  );

  if (res.body.contains("User Login")) {
    await AuthService().login();

    res = await get(
      Uri.parse("https://eduserve.karunya.edu/Student/SemSummary.aspx"),
      headers: AuthService.headers,
    );
  }

  Document html = Document.html(res.body);

  List<Element> rows = html
      .querySelectorAll("tr")
      .where((e) => e.className == "rgRow" || e.className == "rgAltRow")
      .toList();

  List<SemesterSummaryResult> semesterSummary = [];

  for (var row in rows) {
    List<String> result = html
        .querySelectorAll("#${row.id} > td")
        .map((e) => e.text.trim())
        .toList();

    semesterSummary.add(
      SemesterSummaryResult(
          monthAndYear: result[0],
          arrears: int.tryParse(result[2]) ?? 0,
          sgpa: double.tryParse(result[3]) ?? 0,
          cgpa: double.tryParse(result[4]) ?? 0),
    );
  }

  return semesterSummary;
}
