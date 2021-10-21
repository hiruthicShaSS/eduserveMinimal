// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/service/scrap.dart';

Future<List> getAttendance() async {
  if (Scraper.cache.containsKey("att")) return Scraper.cache["att"];

  Map<String, String> headers = httpHeaders;

  Response page = await get(
      Uri.parse("https://eduserve.karunya.edu/Student/Home.aspx"),
      headers: headers);

  if (page.body.indexOf("Hourly Feedback") != -1) {
    return ["feedback form found"];
  }

  Beautifulsoup attendanceSoup = Beautifulsoup(page.body);
  List attendenceList = attendanceSoup
      .find_all("span")
      .map((e) => (e.attributes["id"] == "mainContent_LBLCLASS" ||
              e.attributes["id"] == "mainContent_LBLASSEMBLY" ||
              e.attributes["id"] == "mainContent_LBLARREAR")
          ? e.text
          : null)
      .toList();
  attendenceList.removeWhere((element) => element == null);

  Scraper.cache["att"] = attendenceList;
  return attendenceList;
}
