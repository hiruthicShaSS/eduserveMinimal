// 📦 Package imports:
import 'package:eduserveMinimal/global/service/month_to_int.dart';
import 'package:eduserveMinimal/models/semester_summary_result.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/network_service.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

Future<List<SemesterSummaryResult>> getSemesterSummary() async {
  NetworkService _networkService = NetworkService();

  Response res = await _networkService.get(
    Uri.parse("https://eduserve.karunya.edu/Student/SemSummary.aspx"),
    headers: AuthService.headers,
  );

  if (res.body.contains("User Login")) {
    await AuthService().login();

    res = await _networkService.get(
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

    DateTime monthAndYear = DateTime(
      int.tryParse(result[0].split(" ").last) ?? 2002,
      monthToInt(result[0].split(" ").first),
    );

    semesterSummary.add(
      SemesterSummaryResult(
          monthAndYear: monthAndYear,
          arrears: int.tryParse(result[2]) ?? 0,
          sgpa: double.tryParse(result[3]) ?? 0,
          cgpa: double.tryParse(result[4]) ?? 0),
    );
  }

  return semesterSummary;
}
