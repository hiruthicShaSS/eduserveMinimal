// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:eduserveMinimal/service/login.dart';

// Flutter importimport 'package:flutter/material.dart';



class Scraper {
  static BuildContext? mainPageContext;
  static String status = "";
  late SharedPreferences prefs;
  late Client client;
  static Map pages = {};
  String hostname = "https://eduserve.karunya.edu";
  String url = "";
  static Map cache = {};

  Map<String, String> headers = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36 Edg/87.0.664.66",
    "accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "content-type": "application/x-www-form-urlencoded",
    "origin": "https://eduserve.karunya.edu",
    "referer": "",
    "sec-fetch-dest": "document",
    "sec-fetch-mode": "navigate",
    "sec-fetch-site": "same-origin",
    "sec-fetch-user": "?1",
    "upgrade-insecure-requests": "1"
  };

  Map formData = {
    "RadScriptManager1_TSM":
        ";;System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35:en-US:1b322a7c-dfaa-439f-aa80-5f3d155ef91d:ea597d4b:b25378d2;Telerik.Web.UI:en-US:a519da8a-d673-48a9-9976-4b08756261d2:16e4e7cd:f7645509:22a6274a:33715776:24ee1bba:e330518b:2003d0b8:c128760b:1e771326:88144a7a:c8618e41:1a73651d:333f8d94:58366029:f46195d3",
    "__EVENTTARGET": "ctl00\$mainContent\$DDLACADEMICTERM",
    "__EVENTARGUMENT": "",
    "__LASTFOCUS": "",
    "__VIEWSTATE": "",
    "__VIEWSTATEGENERATOR": "",
    "__PREVIOUSPAGE": "",
    "__EVENTVALIDATION": "",
    "ctl00_radMenuModule_ClientState": "",
    "ctl00\$mainContent\$DDLACADEMICTERM": "",
    "ctl00_mainContent_grdData_ClientState": "",
  };

  Scraper() {
    client = new Client();
    initAsyncMethods();
  }

  Future<void> initAsyncMethods() async {
    prefs = await SharedPreferences.getInstance();
  }

  int totalFeedback = 0;

  Future<void> fillFeedbackForm(Map rating) async {
    Map feedback_data = formData;
    Map<String, String> headers = this.headers;

    var soup = Beautifulsoup(pages["hfb"].body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();

    final RegExp exp = RegExp(
        r"ctl00_mainContent_grdHFB_ctl00_ctl\d{1,2}_rtngHFB_ClientState");

    List feedbackIds = feedback_data.keys
        .map((e) => (exp.allMatches(e).length > 0) ? e : null)
        .toList();
    feedbackIds.removeWhere((element) => element == null);
    // print(feedbackIds);

    inputs.forEach((element) {
      if (!element["name"]!.contains("ClassHandle")) {
        feedback_data[element["name"]] = element["value"];
      }
    });

    feedbackIds.forEach((id) async {
      feedback_data[id] = {"value": "1", "readOnly": false}.toString();
      Response response = await client.post(
          Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
          headers: headers,
          body: jsonEncode(feedback_data));
      // print(response.statusCode);
      // Repopulate data with new values after each rating request
      var soup = Beautifulsoup(response.body);
      final inputs = soup.find_all("input").map((e) => e.attributes).toList();

      inputs.forEach((element) {
        if (!element["name"]!.contains("ClassHandle")) {
          feedback_data[element["name"]] = element["value"];
        }
      });
    });

    feedback_data["ctl00_radMenu_ClientState"] = "";
    feedback_data["__VIEWSTATEGENERATOR"] = ""; // More form data required

    feedback_data.forEach((key, value) => print("$key => $value"));

    // Response response = await client.post(
    //     Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
    //     headers: headers,
    //     body: jsonEncode(feedback_data));
    // print(response.body);
    // print(response.statusCode);
  }

  Future<List?> getAttendenceSummary({String? term}) async {
    Map<String, String> headers = this.headers;
    Map formData = this.formData;

    // headers[":authority:"] = "eduserve.karunya.edu";
    // headers[":method:"] = "GET";
    // headers[":path:"] = "/Student/AttSummary.aspx";
    // headers[":scheme:"] = "https";
    headers["referer"] = "https://eduserve.karunya.edu/Student/AttSummary.aspx";
    headers["accept-encoding"] = "gzip, deflate, br";
    headers["accept-language"] = "en-US,en;q=0.9";
    headers["sec-ch-ua"] =
        '"Chromium";v="94", "Microsoft Edge";v="94", ";Not A Brand";v="99"';
    headers["cache-control"] = "max-age=0";
    headers["content-length"] = "16209";

    if (term == null) {
      Response res = await this.client.get(
          Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
          headers: headers);

      if (res.body.indexOf("Login") == -1) login();

      var soup = Beautifulsoup(res.body);
      final inputs = soup.find_all("input").map((e) => e.attributes).toList();
      List academicTerms = soup
          .find_all("option")
          .map((e) => {e.text.trim(): e.attributes})
          .toSet()
          .toList();

      inputs.forEach((element) {
        // Populate form data
        if (formData[element["name"]] == "") {
          formData[element["name"]] =
              (element["value"] == "Clear" || element["value"] == null)
                  ? ""
                  : element["value"];
        }
      });
      return academicTerms;
    } else {
      // headers[":method:"] = "POST";
      formData["ctl00\$mainContent\$DDLACADEMICTERM"] = term;
      formData.remove("ctl00\$mainContent\$DDLEXAM");

      Response res = await client.post(
          Uri.parse("https://eduserve.karunya.edu/Student/AttSummary.aspx"),
          headers: headers,
          body: formData);

      Beautifulsoup soup = Beautifulsoup(res.body);
      final a = soup.find_all("td").map((e) => e.text).toList();
      final selectedOption = soup
          .find_all("option")
          .where((e) => e.attributes.containsKey("selected"))
          .toList();

      if (a.contains("No records to display.")) return [];
      a.forEach((element) => print(element));
    }
  }
}
