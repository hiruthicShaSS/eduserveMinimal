import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:http/http.dart';

Future<Map<String, List>> getAttendanceSummary([retries = 0]) async {
  Map<String, String> headers = httpHeaders;
  Map formData = httpFormData;
  formData.remove("ctl00\$mainContent\$DDLEXAM");

  headers["referer"] = "https://eduserve.karunya.edu/Student/AttSummary.aspx";
  Response res = await get(
      Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
      headers: headers);

  var soup = Beautifulsoup(res.body);
  final inputs = soup.find_all("input").map((e) => e.attributes).toList();

  final academicTerms =
      soup.find_all("option").map((e) => e.text.trim()).toSet().toList();
  int maxAcademicTerm = academicTerms.length -
      1; // -1 for for compensating 0 indexing and to remove the option 'Select the Academic Term'

  inputs.forEach((element) {
    // Populate form data
    if (formData[element["name"]] == "") {
      formData[element["name"]] =
          (element["value"] == "Clear" || element["value"] == null)
              ? ""
              : element["value"];
    }
  });

  formData["ctl00\$mainContent\$DDLACADEMICTERM"] = maxAcademicTerm.toString();
  res = await post(
      Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
      headers: headers,
      body: formData);
  soup = Beautifulsoup(res.body);

  const basicInfoStart = 46;
  const summaryDataStart = 38;

  List basicInfo = soup.find_all("span").map((e) => e.text).toList();

  if (basicInfo.length == 0 && retries == 0)
    return getAttendanceSummary(++retries);
  basicInfo = basicInfo.sublist(basicInfoStart);
  // basicInfo [Semester, email, phone, ANDREW, SRA, Status, Total Hours : , total_hour_value, Present Hours : , present_hour_value, actual, od_corrected, ml_corrected, Leave Hours : , leave_hours_value, Absent Hours : , absent_hours_value]

  List summary = soup.find_all("td").map((e) => e.text.trim()).toList();
  summary = summary.sublist(summaryDataStart);

  List<List> summaryData = [];
  for (int i = 0; i < summary.length; i += 14) {
    try {
      summaryData.add(summary.sublist(i, i + 14));
    } catch (e) {}
  }

  for (int i = 0; i < summaryData.length; i++) {
    int totalPresent = summaryData[i].where((e) => e == "P").toList().length;
    int totalAbsent = summaryData[i].where((e) => e == "A").toList().length;
    int totalUnAttended = summaryData[i].where((e) => e == "U").toList().length;

    summaryData[i].add(totalPresent.toString());
    summaryData[i].add(totalAbsent.toString());
    summaryData[i].add(totalUnAttended.toString());
  }

  return {
    "basicInfo": basicInfo,
    "summaryData": summaryData,
  };
}
