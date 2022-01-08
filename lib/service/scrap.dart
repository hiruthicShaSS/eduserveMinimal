// Flutter imports:
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future<String> login([callback]) async {
    // Login
    var connection = await (Connectivity().checkConnectivity());
    if (connection == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "Internet, caveman. Turn it on...",
        timeInSecForIosWeb: 10,
      );
    }

    String loginAddress = "/Login.aspx?ReturnUrl=%2f";

    String username = prefs.getString("username")!;
    String password = prefs.getString("password")!;

    Map<String, String> login_data = {
      "RadScriptManager1_TSM": "",
      "__EVENTTARGET": "",
      "__EVENTARGUMENT": "",
      "__VIEWSTATE": "",
      "__VIEWSTATEGENERATOR": "",
      "__EVENTVALIDATION": "",
      "ctl00\$mainContent\$Login1\$UserName": username,
      "ctl00\$mainContent\$Login1\$Password": password,
      "ctl00\$mainContent\$Login1\$LoginButton": "Log In"
    };

    status = "Get EduServe...";

    // Get karunya.edu
    url = hostname;
    headers["referer"] = url;
    var res = await client.get(Uri.parse(url));
    var eduserveCookie = res.headers["set-cookie"]; // Set the ASP.NET_SessionId

    // Parse: Start
    var soup = Beautifulsoup(res.body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();

    inputs.forEach((element) {
      if (login_data[element["name"]] == "") {
        login_data[element["name"]!] = element["value"]!;
      }
    });
    // Parse: End

    // Get login.aspx
    status += "\nLogging in...";
    headers["cookie"] = eduserveCookie!.split(";")[0];
    url = hostname + loginAddress;
    headers["referer"] = url;

    // Post to login.aspx
    res = await client.post(Uri.parse(url), headers: headers, body: login_data);

    if (res.body.indexOf(
            "Your login attempt was not successful. Please try again.") !=
        -1) {
      Fluttertoast.showToast(
          msg: "Your login attempt was not successful. Please try again.",
          gravity: ToastGravity.CENTER);
    }

    if (res.statusCode == 302) {
      status += "\nRedirecting to Home";
      headers["cookie"] =
          headers["cookie"]! + "; ${res.headers['set-cookie']!.split(';')[0]}";
      res = await client.get(
          Uri.parse("https://eduserve.karunya.edu${res.headers["location"]}"),
          headers: headers);
    }

    if (res.body.contains("Hourly Feedback")) {
      return "feedback form found";
    }
    return res.body;
  }

  Future<Map> getFeesDetails({bool force = false}) async {
    if (cache.containsKey("fees")) return cache["fees"];

    String feesDownload = "/Student/Fees/DownloadReceipt.aspx";
    String feesOverallStatement = "/Student/Fees/FeesStatement.aspx";
    Map feesStatement = new Map();

    Response page = await client.get(Uri.parse("$hostname${feesDownload}"),
        headers: headers);

    if (page.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return {};
    }

    Response dues = await client
        .get(Uri.parse("$hostname${feesOverallStatement}"), headers: headers);
    var dueSoup = Beautifulsoup(dues.body);
    List dueslist = dueSoup
        .find_all("span")
        .map((e) => (e.attributes["id"] == "mainContent_LBLDUES" ||
                e.attributes["id"] == "mainContent_LBLEXCESS")
            ? e.text
            : "")
        .toSet()
        .toList();
    dueslist.removeWhere((element) => element == "");

    var soup = Beautifulsoup(page.body);
    List table = soup.find_all("tr").map((e) => e.innerHtml).toSet().toList();

    bool flagReached = false;
    table.forEach((element) {
      if (element.indexOf("Total Amount") != -1) {
        flagReached = true;
        return;
      }
      if (flagReached) {
        element = element.trim().replaceAll("<td>", "");
        element = element.trim().replaceAll('<td style="display:none;">', "");
        element = element.trim().replaceAll("</td>", "<space>");

        List temp = [];
        temp = element.split("<space>");
        temp.removeRange(0, 3);
        temp.removeWhere((element) => element.length == 0);
        feesStatement[temp[1]] = temp;
      }
    });

    feesStatement["dues"] = dueslist;
    cache["fees"] = feesStatement;
    return feesStatement;
  }

  Future<Map> getTimetable({bool force = false}) async {
    final String timetableURL = "/Student/TimeTable.aspx";

    headers["referer"] = "https://eduserve.karunya.edu/Student/TimeTable.aspx";
    Response res =
        await client.get(Uri.parse("$hostname$timetableURL"), headers: headers);

    if (res.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return {};
    }

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

    formData["ctl00\$mainContent\$DDLACADEMICTERM"] =
        maxAcademicTerm.toString();
    res = await client.post(Uri.parse("$hostname$timetableURL"),
        headers: headers, body: formData);
    soup = Beautifulsoup(res.body);
    List classes = soup.find_all("td").map((e) => e.text).toList();

    List days = ["MON", "TUE", "WED", "THU", "FRI"];
    List tempList = [];
    Map data = new Map();
    days.forEach((day) {
      int dayIndex = classes.indexOf(day);
      tempList = classes.sublist(dayIndex + 1, dayIndex + 12);
      data[day] = tempList;
    });

    return data;
  }
}
