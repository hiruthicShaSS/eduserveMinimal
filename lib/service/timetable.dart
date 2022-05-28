// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/timetable.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/dom.dart';

Future<List<TimeTable>> getTimetable([bool supressError = false]) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  DateTime today = DateTime.now();
  int lastUpdate = 100;

  if (prefs.containsKey("timetable_last_update")) {
    lastUpdate = today
        .difference(DateTime.parse(prefs.getString("timetable_last_update")!))
        .inDays;
  }

  if (await storage.containsKey(key: "timetable") && lastUpdate < 90) {
    String? timetableString = await storage.read(key: "timetable");

    if (timetableString != null) {
      List timetableList = jsonDecode(timetableString);
      timetableList = timetableList.map((e) => jsonDecode(e)).toList();

      List<TimeTable> timetable =
          timetableList.map((e) => TimeTable.fromMap(e)).toList();

      return timetable;
    }
  }

  Map<String, String> formData = AuthService.formData;
  formData.remove(r"ctl00$mainContent$BTNCLEAR");

  Response res = await get(
    Uri.parse("https://eduserve.karunya.edu/Student/TimeTable.aspx"),
    headers: AuthService.headers,
  );

  String? loginPage;
  if (res.body.contains("User Login")) {
    loginPage = await AuthService().login();
  }

  Document html = Document.html(loginPage ?? res.body);
  List inputs = html
      .querySelectorAll("input")
      .map((e) => {e.attributes["name"]: e.attributes["value"]})
      .toList();

  inputs.removeWhere(
      (element) => element.keys.first == null || element.values.first == null);

  for (var input in inputs) {
    formData[input.keys.first!] = input.values.first;
  }

  List<String> academicTerms = html
      .querySelectorAll("#mainContent_DDLACADEMICTERM > option")
      .map((node) => node.innerHtml.trim())
      .toList();

  formData[r"ctl00$mainContent$DDLACADEMICTERM"] =
      (academicTerms.length - 1).toString();
  formData.remove(r"ctl00$mainContent$BTNCLEAR");

  res = await post(
    Uri.parse("https://eduserve.karunya.edu/Student/TimeTable.aspx"),
    headers: AuthService.headers,
    body: formData,
  );

  if (!supressError) {
    if (res.body.contains("No records to display.")) {
      throw NoRecordsException("No timetable records to display.");
    }

    if (res.body.contains("Object moved to")) {
      throw MiscellaneousErrorInEduserve("Error fetching timetable data.");
    }
  }

  html = Document.html(res.body);

  List<Element> rows = html
      .querySelectorAll("tr")
      .where((e) => e.className == "rgRow" || e.className == "rgAltRow")
      .toList();

  List<TimeTable> table = [];
  for (var row in rows) {
    List<String> rowData = html
        .querySelectorAll("#${row.id} > td")
        .map((e) => e.text.trim())
        .toList();

    TimeTable timeTable = TimeTable(
      day: rowData[0],
      hour1: TimeTableSubject.fromString(rowData[1]),
      hour2: TimeTableSubject.fromString(rowData[2]),
      hour3: TimeTableSubject.fromString(rowData[3]),
      hour4: TimeTableSubject.fromString(rowData[4]),
      hour5: TimeTableSubject.fromString(rowData[5]),
      hour6: TimeTableSubject.fromString(rowData[6]),
      hour7: TimeTableSubject.fromString(rowData[7]),
      hour8: TimeTableSubject.fromString(rowData[8]),
      hour9: TimeTableSubject.fromString(rowData[9]),
      hour10: TimeTableSubject.fromString(rowData[10]),
      hour11: TimeTableSubject.fromString(rowData[11]),
    );

    table.add(timeTable);
  }

  await storage.write(key: "timetable", value: jsonEncode(table));
  await prefs.setString("timetable_last_update", DateTime.now().toString());

  return table;
}
