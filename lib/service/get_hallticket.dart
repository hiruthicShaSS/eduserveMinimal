// 📦 Package imports:
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/hallticket/subject.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

Future<HallTicket> getHallTicket() async {
  Response res = await get(
    Uri.parse(
        "https://eduserve.karunya.edu/Student/CBCS/HallTicketDownload.aspx"),
    headers: AuthService.headers,
  );

  Document html = Document.html(res.body);

  List<String> academicTerms = html
      .querySelectorAll("#mainContent_DDLEXAM > option")
      .map((node) => node.attributes["value"] ?? "")
      .toList();

  academicTerms.removeWhere((element) => element.isEmpty || element == "-1");

  Map<String, String> formData = await AuthService().basicFormData(res.body);

  if (academicTerms.isEmpty) {
    throw MiscellaneousErrorInEduserve();
  }

  formData[r"ctl00$mainContent$DDLEXAM"] = academicTerms.last.toString();
  formData.remove(r"ctl00$mainContent$Login1$LoginButton");

  res = await post(
    Uri.parse(
        "https://eduserve.karunya.edu/Student/CBCS/HallTicketDownload.aspx"),
    headers: AuthService.headers,
    body: formData,
  );

  if (res.body.contains("No records to display.")) {
    throw NoHallTicketAvailable("No records to display.");
  }

  html = Document.html(res.body);

  HallTicket hallTicket = HallTicket(
    attendanceEligibility:
        html.querySelector("#mainContent_LBLATTENDANCE")?.text == "Eligible",
    feesEligibility:
        html.querySelector("#mainContent_LBLDUES")?.text == "Eligible",
    examEligibility:
        html.querySelector("#mainContent_LBLELIGIBILITY")?.text == "Eligible",
    subjects: [],
  );

  List<Element> rows = html
      .querySelectorAll("tr")
      .where((e) => e.className == "rgRow" || e.className == "rgAltRow")
      .toList();

  for (var row in rows) {
    List<String> rowData = html
        .querySelectorAll("#${row.id} > td")
        .map((e) => e.text.trim())
        .toList();

    Subject subject = Subject(
      code: rowData[0],
      name: rowData[1],
      eligible: rowData[2] == "Y",
    );

    hallTicket.subjects.add(subject);
  }

  return hallTicket;
}
