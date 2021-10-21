// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/service/scrap.dart';

Future<Map<String, List<List<String>>>> getLeaveInfo() async {
  if (Scraper.cache.containsKey("leave")) return Scraper.cache["leave"];
  Map<String, String> headers = httpHeaders;

  Map<String, List<List<String>>> parsePage(String page) {
    String onDutySection = page.toString().split("Leave Type")[1];

    Beautifulsoup onDutySoup = Beautifulsoup(onDutySection);
    List onDuties = onDutySoup.find_all("td").map((e) => e.text).toList();

    Beautifulsoup leaveSoup = Beautifulsoup(page.toString());
    List leavest = leaveSoup.find_all("td").map((e) => e.text).toList();
    leavest = leavest.sublist(leavest.indexOf("Medical Leave"));

    List<List<String>> allLeave = [];
    List<List<String>> allOnDuty = [];
    // onDuty structure [From Date, From Session, To Date, To Session, Reason, Status, Pending with, Created by, Created on, Approval by,
    // Approval on, Availed by, Availed on]
    List<String> onDuty = [];
    RegExp dateRegExp =
        RegExp(r"\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{1,2}:\d{1,2} \w{2}");

    List<String> leave = [];
    int leaveEntryCount = 0;
    for (int i = 0; i < leavest.length; i++) {
      if (int.tryParse(leavest[i]) == null) {
        leave.add(leavest[i]);
        leaveEntryCount++;
        if (leaveEntryCount > 8) {
          allLeave.add(leave);
          break;
        }
      } else {
        allLeave.add(leave);
        leave = [];
        leaveEntryCount = 0;
      }
    }

    onDuties.forEach((element) {
      final datetimesOnTable = onDuty
          .map((e) =>
              (dateRegExp.allMatches(e.toString()).length > 0) ? e : null)
          .toList();
      datetimesOnTable.removeWhere((element) => element == null);

      if (onDuty.length == 13) {
        if (onDuty.first == "") {
          onDuty.removeAt(0);
          onDuty.add(element);
          return;
        }
        allOnDuty.add(onDuty);
        onDuty = [element];
        return;
      }

      if (element.toString().trim() == "No records to display.") return;
      onDuty.add(element.toString().trim());
    });

    Scraper.cache["leave"] = {"onDuty": allOnDuty, "leave": allLeave};
    return {"onDuty": allOnDuty, "leave": allLeave};
  }

  Response home_page = await get(
      Uri.parse("https://eduserve.karunya.edu/Student/Home.aspx"),
      headers: headers);
  Scraper.pages["home"] = home_page.body;
  return parsePage(home_page.body);
}
