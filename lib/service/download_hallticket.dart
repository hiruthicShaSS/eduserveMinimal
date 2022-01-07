// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/service/login.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List?> downloadHallTicket(
    {String? term, bool download = false, int retry = 0}) async {
  final String hallticketURL = "/Student/CBCS/HallTicketDownload.aspx";
  Map<String, String> headers = httpHeaders;
  Map formData = httpFormData;

  if (term == null) {
    Response res = await get(
        Uri.parse("https://eduserve.karunya.edu$hallticketURL"),
        headers: headers);
    if (res.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "Session expired. Refresh data!");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", false);
      return null;
    }

    var soup = Beautifulsoup(res.body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();

    inputs.forEach((element) {
      // Populate form data
      if (formData[element["name"]] == "") {
        formData[element["name"]] =
            (element["value"] == "Clear" || element["value"] == null)
                ? ""
                : element["value"];
      }
    });

    final examination = soup
        .find_all("option")
        .map((e) => {e.text.trim(): e.attributes})
        .toSet()
        .toList();

    return examination;
  } else {
    formData["ctl00\$mainContent\$DDLEXAM"] = term;

    if (download) {
      headers["referer"] =
          "https://eduserve.karunya.edu/Student/CBCS/HallTicketDownload.aspx";
      headers["Sec-Fetch-Dest"] = "document";
      headers["sec-ch-ua"] = ';Not A Brand";v="99", "Chromium";v="94"';
      headers["sec-ch-ua-mobile"] = "?0";
      headers["sec-ch-ua-platform"] = "Windows";
      headers["sec-fetch-dest"] = "document";
      headers["sec-fetch-mode"] = "navigate";
      headers["sec-fetch-site"] = "same-origin";
      headers["sec-fetch-user"] = "?1";

      formData["ctl00\$mainContent\$BTNDOWNLOAD"] = "Download";
      formData["__EVENTTARGET"] = "";
      formData.remove("ctl00\$mainContent\$DDLACADEMICTERM");
      Response res = await post(
          Uri.parse("https://eduserve.karunya.edu$hallticketURL"),
          headers: headers,
          body: formData);

      print(res.headers);
      return [];
    }

    if (Scraper.cache.containsKey("hallticket"))
      return Scraper.cache["hallticket"];

    formData["ctl00\$mainContent\$DDLACADEMICTERM"] = "";
    Response res = await post(
        Uri.parse("https://eduserve.karunya.edu$hallticketURL"),
        headers: headers,
        body: formData);

    if (res.body.indexOf("No records to display.") != -1) {
      Scraper.cache["hallticket"] = ["No records to display."];
      return null;
    }

    Beautifulsoup hallticketSoup = Beautifulsoup(res.body);
    List eligibility =
        hallticketSoup.find_all("td").map((e) => e.text.trim()).toList();

    List endFlag = eligibility.map((e) => e.length > 80 ? e : null).toList();
    endFlag.removeWhere((element) => element == null);
    if (endFlag.length == 0) {
      Fluttertoast.showToast(
          msg: "Something went wrong please restart the app");
      login();
      if (retry == 2) return [];
      return downloadHallTicket(term: term, retry: retry + 1);
    }
    int end = eligibility.indexOf(endFlag.first);

    List mainEligibility = eligibility.sublist(
        eligibility.indexOf("Attendance Eligibility?:"), end);
    eligibility = eligibility.sublist(end + 1);

    Map hallTicketdata = {};
    for (int i = 0; i < mainEligibility.length; i++) {
      hallTicketdata[mainEligibility[i]] = mainEligibility[i];
    }

    List subjectData = [];
    List allEligibility = [];
    for (int i = 0; i < eligibility.length; i++) {
      subjectData.add(eligibility[i]);

      if (subjectData.length == 3) {
        allEligibility.add(subjectData);
        subjectData = [];
      }
    }

    formData.remove("ctl00\$mainContent\$DDLEXAM");
    Scraper.cache["hallticket"] = [mainEligibility, allEligibility];
    return [mainEligibility, allEligibility];
  }
}
