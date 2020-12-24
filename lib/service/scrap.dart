import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart';
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

class Scraper {
  static BuildContext mainPageContext;
  static String status = "";
  SharedPreferences prefs;

  String hostname = "https://eduserve.karunya.edu";
  String url = "";

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

  Client client = new Client();

  int bypassFeedbackForm(int stars) {
    // TODO: Implement bypass code for feedback form.
    return 0;
  }

  Future<String> login([callback]) async {
    var connection = await (Connectivity().checkConnectivity());
    if (connection == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg:
            "Are you a caveman? coz you didn't know that we need internet to access a webpage.😂",
        timeInSecForIosWeb: 10,
      );
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File loginData = File("$appDocPath/loginData.json");

    String loginAddress = "/Login.aspx?ReturnUrl=%2f";

    prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username");
    String password = prefs.getString("password");
    int stars = prefs.getInt("stars");

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

    try {
      if (await loginData.readAsString() != null) {
        Map data = jsonDecode(await loginData.readAsString());
        login_data = data["login"];
        headers = data["headers"];
      }
    } catch (e) {}

    status = "Get EduServe...";

    // Get karunya.edu
    url = hostname;
    headers["referer"] = url;
    var res = await client.get(url);
    var eduserveCookie = res.headers["set-cookie"]; // Set the ASP.NET_SessionId

    // Parse: Start
    var soup = Beautifulsoup(res.body);
    final inputs = soup.find_all("input").map((e) => e.attributes).toList();

    inputs.forEach((element) {
      if (login_data[element["name"]] == "") {
        login_data[element["name"]] = element["value"];
      }
    });
    // Parse: End

    // Get login.aspx
    status += "\nLogging in...";
    headers["cookie"] = eduserveCookie.split(";")[0];
    url = hostname + loginAddress;
    headers["referer"] = url;

    // Post to login.aspx
    res = await client.post(url, headers: headers, body: login_data);

    if (res.body.indexOf(
            "Your login attempt was not successful. Please try again.") !=
        -1) {
      Fluttertoast.showToast(
          msg:
              "EduServe: Your login attempt was not successful. Please try again.",
          gravity: ToastGravity.CENTER);
    }

    if (res.statusCode == 302) {
      status += "\nRedirecting to Home";
      headers["cookie"] += "; ${res.headers['set-cookie'].split(';')[0]}";
      res = await client.get(
          "https://eduserve.karunya.edu${res.headers["location"]}",
          headers: headers);
    }

    loginData
        .writeAsString(jsonEncode({"headers": headers, "login": login_data}));

    return res.body;
  }

  Future<Map> fees({bool force = false}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File fees = File("$appDocPath/fees.json");

    if (force) {
      try {
        if (await fees.readAsString() != null) {
          return jsonDecode(await fees.readAsString());
        }
      } catch (e) {}
    }

    String feesDownload = "/Student/Fees/DownloadReceipt.aspx";
    String feesOverallStatement = "/Student/Fees/FeesStatement.aspx";
    Map feesStatement = new Map();

    Response page =
        await client.get("$hostname${feesDownload}", headers: headers);

    Response dues =
        await client.get("$hostname${feesOverallStatement}", headers: headers);
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
    List td = soup
        .find_all("td")
        .map((e) => (e.attributes.keys.length == 0) ? e.text : "")
        .toList();

    RegExp recieptExp = new RegExp(r"[RE]\d{1,7}");
    RegExp dateExp = new RegExp(r"\d{2} \w{3} \d{4}");
    RegExp amountExp = new RegExp(r"\d{1,}\.\d{1,}");

    List reArrangeFees(List list) {
      String reciept = "";
      String date = "";
      String amount = "";
      String title = "";
      String currency = "";
      list.forEach((element) {
        if (recieptExp.hasMatch(element)) {
          reciept = element;
        } else if (dateExp.hasMatch(element)) {
          date = element;
        } else if (amountExp.hasMatch(element)) {
          amount = element;
        } else {
          title = element;
        }
      });
      return [reciept, date, amount, title];
    }

    bool flagReached = false;
    bool flagStop = false;
    int flagLines = 0;

    String temp = "";
    td.forEach((element) {
      element = element.trim();

      if (recieptExp.hasMatch(element) && element.length < 40) {
        flagReached = true;
      }

      if (flagReached) {
        if (element.length <= 2) {
          // If the element is just 'A' or any stray characters, return.
          return false;
        }

        if (flagLines != 5) {
          temp += "$element<space>";
          flagLines++;
        } else {
          List splited = temp
              .split("<space>")
              .toSet()
              .toList(); // Once completed parse the string to list.
          splited.removeWhere(
              (element) => element.toString() == ""); // Remove empty elements.
          splited.removeWhere((element) => element == "Indian Rupee");
          temp = "";
          flagLines = 0;

          // Somethings messing with the position of elements to be in same order
          splited = reArrangeFees(splited);
          feesStatement[splited[0]] = splited.sublist(1);
        }
      }
    });

    feesStatement["dues"] = dueslist;

    fees.writeAsString(jsonEncode(feesStatement));

    return feesStatement;
  }

  Future<Map> timetable({bool force = false}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File timetableFile = File("$appDocPath/timetable.json");

    try {
      if (await timetableFile.readAsString() != "") {
        return jsonDecode(await timetableFile.readAsString());
      }
    } catch (e) {}

    final String timetableURL = "/Student/TimeTable.aspx";
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

    headers["referer"] = "https://eduserve.karunya.edu/Student/TimeTable.aspx";
    Response res = await client.get("$hostname$timetableURL", headers: headers);
    // print(res.body);

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
    res = await client.post("$hostname$timetableURL",
        headers: headers, body: formData);
    soup = Beautifulsoup(res.body);
    List classes = soup.find_all("td").map((e) => e.text).toList();

    List days = ["MON", "TUE", "WED", "THU", "FRI"];
    List tempList = new List();
    Map data = new Map();
    days.forEach((day) {
      int dayIndex = classes.indexOf(day);
      tempList = classes.sublist(dayIndex + 1, dayIndex + 12);
      data[day] = tempList;
    });

    await timetableFile.writeAsString(jsonEncode(data));

    return data;
  }

  Future<Map> parse() async {
    // Parse the student basic info
    String studentHomePage = await login();
    status += "\nScrapping data...";

    var soup = Beautifulsoup(studentHomePage);
    List basicInfo =
        soup.find_all("span").map((e) => (e.innerHtml)).toList().sublist(54);
    String studentImage =
        soup.find_all("img").map((e) => (e.attributes["src"])).toList()[2];
    List td = soup.find_all("td").map((e) => (e.text)).toList();

    bool flagReached = false;
    bool flagStop = false;
    int flagLines = 0;
    Map leaveApplication = new Map();

    RegExp leaveTypeExp = new RegExp(r"[^\d\s].*Leave");

    String temp = "";
    td.forEach((element) {
      if (!flagStop) {
        element = element.trim();
        if (element == "No records to display.") {
          flagStop = true;
        }

        if (leaveTypeExp.hasMatch(element)) {
          // if leave applications found set the flag to true.
          flagReached = true;
        }

        if (flagReached) {
          // Wait untill the leave applications found.
          if (flagLines != 8) {
            // 7 items in the application section -> [Leave Type, Reason, From Date, From Session, To Date, To Session, Status, Pending with]
            temp +=
                "$element<space>"; // Add each one of'em with delimiter : <space>
            flagLines++;
          } else {
            List splited = temp
                .split("<space>"); // Once completed parse the string to list.
            splited
                .removeWhere((element) => RegExp(r"\d{5,}").hasMatch(element));
            splited.asMap().forEach((i, value) {
              splited[i] = splited[i].trim();
            });
            splited.removeWhere((element) =>
                element.toString() == ""); // Remove empty elements.
            leaveApplication[splited[1]] = splited;

            flagLines = 0;
            temp = "";
          }
        }
      } else {
        return;
      }
    });

    basicInfo.add(studentImage);
    basicInfo.removeWhere(
        (element) => element.toString() == ""); // Remove empty elements
    basicInfo.remove("Academic Performance Summary");

    List basicInfoKeys = [
      "reg",
      "kmail",
      "name",
      "mobile",
      "programme",
      "mentor",
      "semester",
      "att",
      "asm",
      "cgpa",
      "arrears",
      "resultOf",
      "credits",
      "cgpa",
      "sgpa",
      "nonAcademicCredits",
      "studentIMG"
    ];

    // generate Map of infromation
    Map data = new Map();
    basicInfoKeys.asMap().forEach((i, element) {
      data[basicInfoKeys[i]] = basicInfo[i];
    });

    data["leaveApplications"] = leaveApplication;

    return data;
  }

  Future<Map> getInfo() async {
    status += "Done.";

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File cacheData = File("$appDocPath/cacheData.json");

    Future<Map> getFreshData() async {
      Map data = await parse();
      data["dateScraped"] = DateTime.now().toString();
      cacheData.writeAsString(jsonEncode(data));
      Fluttertoast.showToast(msg: "New data cached!");
      return data;
    }

    try {
      Map data = jsonDecode(await cacheData.readAsString());
      int lastScraped = DateTime.now()
          .difference(DateTime.parse(data["dateScraped"]))
          .inHours;
      if (lastScraped >= 12) {
        return getFreshData();
      }
      data.remove("dateScraped");

      Fluttertoast.showToast(
          msg: "You're viewing a cached copy, refresh to get new copy");
      return data;
    } catch (e) {
      return getFreshData();
    }
  }
}

// "RadScriptManager1_TSM": ";;System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35:en-US:1b322a7c-dfaa-439f-aa80-5f3d155ef91d:ea597d4b:b25378d2;Telerik.Web.UI:en-US:a519da8a-d673-48a9-9976-4b08756261d2:16e4e7cd:f7645509:22a6274a:33715776:24ee1bba:e330518b:2003d0b8:c128760b:1e771326:88144a7a:c8618e41:1a73651d:333f8d94:58366029:f46195d3"
// "__EVENTTARGET": "ctl00$mainContent\$DDLACADEMICTERM"
// "__EVENTARGUMENT":
// "__LASTFOCUS":
// "__VIEWSTATE": "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"
// "__VIEWSTATEGENERATOR": "7E71F5B1"
// "__PREVIOUSPAGE": "WkUD6o34SnR7eWaVVdNS-2Kx9TbjEc-Ofvx6IbizczfRIi2qY7sF4DbcSzzqCFxZopxCwPAp-VWvGw-KvA4qkWNOwY41"
// "__EVENTVALIDATION": "nXu5B8yNKzVRJLD9VdfzNQk/oKFaG+sytxiZUKYDTcmvDrO2nXtWrz5zCBcmsNM1XtrJNVxN886ZG3Wu8zsDkRTWvcCwCT2uoNm3D323Fg7bImyY9LG2gKDkdSMqPirzA4MxCevip2pBCQ6h3KymU4i7i4HorJCML4HRCIe2qQ8zGMbmWewKjv3Sg+y+IcP0WUBE1V3RAEe8SrYRaDKz0coUqDfZpHP38s1Qf3IFUhLCaaqx8GHyFCLfyy3mPDHkrZuwcTSOB1eVVom+rGvtznWhq0e9ofCzIJF/ATsQUl0eLiPKTsaJ5V4x19tjcm9Veb7VO8qvDdAnCPNCRumxojs4Zbo1XlH8ZzZuDcNlraSWXcYb2J8Zv8HdEbKkYVtZKYA8w1VQsWyH1QTVRqhlalOd52wPbhRjFidumGCWRfIKpRlLDnT1IcTwkO8UnHwRqpIgyVudW66TrsREMhG57oMOpUpbXkTXybLmwbP/+Jd52OBq70cIaOdEsjjQR9+bqsg0rl8V5aZNXWINXEG2UZ24TJjR/TCVly6Ri2u26+iLDPcN0a8t1m4z19WMOpzy8gHReg=="
// "ctl00_radMenuModule_ClientState":
// "ctl00\$mainContent\$DDLACADEMICTERM": "19"
// "ctl00_mainContent_grdData_ClientState": ""
