// 📦 Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';

Future<Map<String, List<String>>> getSemesterSummary() async {
  Response res = await get(
      Uri.parse("https://eduserve.karunya.edu/Student/SemSummary.aspx"),
      headers: httpHeaders);
  Beautifulsoup soup = Beautifulsoup(res.body);

  List tds = soup.find_all("td").map((e) => e.text).toList();

  tds = tds.sublist(tds.indexOf("Active") + 2);

  List<List<String>> summaryData = [];
  List<String> temp = [];

  for (int i = 0; i < tds.length; i++) {
    temp.add(tds[i]);

    if (temp.length == 5) {
      summaryData.add(temp);
      temp = [];
    }
  }

  summaryData.sort((a, b) => b.first.compareTo(a.first));
  List<String> months = summaryData.map((e) => e[0]).toList();
  List<String> arrears = summaryData.map((e) => e[2]).toList();
  List<String> scgpa = summaryData.map((e) => e[3]).toList();
  List<String> cgpa = summaryData.map((e) => e[4]).toList();

  Map<String, List<String>> data = {
    "months": months,
    "arrears": arrears,
    "scgpa": scgpa,
    "cgpa": cgpa
  };

  return data;
}
