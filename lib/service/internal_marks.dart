import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/internal_mark.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/network_service.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';

class InternalMarksService {
  NetworkService _networkService = NetworkService();

  List inputs = [];
  static Map<String, String> formData = {};
  AuthService _authService = AuthService();

  Future<List<String>> getInternalAcademicTerms() async {
    Response res = await _networkService.get(
      Uri.parse("https://eduserve.karunya.edu/Student/InternalMarks.aspx"),
      headers: AuthService.headers,
    );

    if (res.body.contains("User Login")) {
      await _authService.login();

      res = await _networkService.get(
        Uri.parse("https://eduserve.karunya.edu/Student/InternalMarks.aspx"),
        headers: AuthService.headers,
      );
    }

    Document html = Document.html(res.body);

    List<String> academicTerms = html
        .querySelectorAll("#mainContent_DDLACADEMICTERM > option")
        .map((node) => node.innerHtml.trim())
        .toList();

    List inputs = html
        .querySelectorAll("input")
        .map((e) => {e.attributes["name"]: e.attributes["value"]})
        .toList();

    inputs.removeWhere((element) =>
        element.keys.first == null || element.values.first == null);

    for (var input in inputs) {
      formData[input.keys.first!] = input.values.first;
    }

    return academicTerms;
  }

  Future<List<InternalMark>> getInternalMarks(int academicTerm) async {
    formData["ctl00\$mainContent\$DDLACADEMICTERM"] = academicTerm.toString();

    Response res = await _networkService.post(
      Uri.parse("https://eduserve.karunya.edu/Student/InternalMarks.aspx"),
      headers: AuthService.headers,
      body: formData,
    );

    if (res.body.contains("User Login")) {
      await _authService.login();

      res = await post(
        Uri.parse("https://eduserve.karunya.edu/Student/InternalMarks.aspx"),
        headers: AuthService.headers,
        body: formData,
      );
    }

    if (res.body.contains("No records to display.")) {
      throw NoRecordsException("No internal marks data found!");
    }

    Document html = Document.html(res.body);
    List<Element> rows = html
        .querySelectorAll("tr")
        .where((e) =>
            e.attributes["class"] == "rgRow" ||
            e.attributes["class"] == "rgAltRow")
        .toList();

    List<InternalMark> internalMarks = [];

    for (var row in rows) {
      List<String> test = html
          .querySelectorAll("#${row.id} > td")
          .map((e) => e.text.trim())
          .toList();

      InternalMark internalMark = InternalMark(
        subjectCode: test[0],
        subjectName: test[1],
        iaParameter: test[2],
        totalMarks: int.tryParse(test[3]) ?? 0,
        marksScored: double.tryParse(test[4]) ?? 0,
        testMarks: double.tryParse(test[5]) ?? 0,
        onlineExamMarks: double.tryParse(test[6]) ?? 0,
        attendance: test[7],
        testDate: DateFormat("dd MMM yyyy").parse(test[8]),
        markEnteredBy: test[9],
        markEnteredOn: DateFormat("dd/MM/yyyy hh:mm:ss aa").parse(test[10]),
      );

      internalMarks.add(internalMark);
    }

    return internalMarks;
  }
}
