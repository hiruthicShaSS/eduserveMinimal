// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/service/scrap.dart';

Future<Map?> getTimetable({bool force = false}) async {
  if (AppState.prefs!.containsKey("timetable"))
    return jsonDecode(AppState.prefs!.getString("timetable")!);

  Scraper scraper = Scraper();
  await scraper.initAsyncMethods();
  await scraper.login();
  final timetable = await scraper.getTimetable();

  await AppState.prefs!.setString("timetable", jsonEncode(timetable));

  return timetable;

  // I dont know why the below implementation works and I spent a lot of time than I should have.
  // So, I am using the old code(the above code) which was working before.

  Map<String, String> headers = httpHeaders;
  Map formData = httpFormData;
  formData.remove("ctl00\$mainContent\$DDLEXAM");

  if (AppState.prefs!.containsKey("timetable"))
    return jsonDecode(AppState.prefs!.getString("timetable")!);

  final String timetableURL = "/Student/TimeTable.aspx";

  headers["referer"] = "https://eduserve.karunya.edu/Student/TimeTable.aspx";
  Response res = await get(
      Uri.parse("https://eduserve.karunya.edu$timetableURL"),
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
  res = await post(Uri.parse("https://eduserve.karunya.edu$timetableURL"),
      headers: headers, body: formData);
  soup = Beautifulsoup(res.body);
  List classes = soup.find_all("td").map((e) => e.text).toList();

  if (res.body.indexOf(
          "You have pending dues so you cannot view timetable. Please pay your dues.") !=
      -1)
    return {
      "__error__":
          "You have pending dues so you cannot view timetable. Please pay your dues."
    };
  if (classes.contains("No records to display.") || classes.length == 0)
    return {"__error__": "No records to display."};

  List days = ["MON", "TUE", "WED", "THU", "FRI"];
  List tempList = [];
  Map data = new Map();

  days.forEach((day) {
    int dayIndex = classes.indexOf(day);
    tempList = classes.sublist(dayIndex + 1, dayIndex + 12);
    data[day] = tempList;
  });

  await AppState.prefs!.setString("timetable", jsonEncode(data));

  return data;
}
