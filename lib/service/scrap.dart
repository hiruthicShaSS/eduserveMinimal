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

  Client client = new Client();

  int bypassFeedbackForm(int stars) {
    // TODO: Implement bypass code for feedback form.
    return 0;
  }

  Future<String> login([callback]) async {
    // Login
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
    // Get fees information
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

    if (page.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return null;
    }

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
    // Get class timetable
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File timetableFile = File("$appDocPath/timetable.json");

    try {
      if (await timetableFile.readAsString() != "") {
        return jsonDecode(await timetableFile.readAsString());
      }
    } catch (e) {}

    final String timetableURL = "/Student/TimeTable.aspx";

    headers["referer"] = "https://eduserve.karunya.edu/Student/TimeTable.aspx";
    Response res = await client.get("$hostname$timetableURL", headers: headers);

    if (res.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return null;
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

  Future<Map> downloadHallTicket() async {
    final String hallticketURL = "/Student/CBCS/HallTicketDownload.aspx";
    Response res =
        await client.get("$hostname$hallticketURL", headers: headers);
    if (res.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return null;
    }

    var soup = Beautifulsoup(res.body);

    final examination =
        soup.find_all("option").map((e) => e.text.trim()).toSet().toList();
    final eligibilities = soup
        .find_all("span")
        .map((e) => (e.attributes["id"] == "mainContent_LBLATTENDANCE")
            ? e.outerHtml
            : "")
        .toSet()
        .toList();

    print(eligibilities);

    return Map();
  }

  Future<dynamic> internalMarks({String academicTerm = null}) async {
    final String internalsURL = "/Student/InternalMarks.aspx";

    if (academicTerm == null) {
      Response res =
          await client.get("$hostname$internalsURL", headers: headers);

      if (res.body.indexOf("Login") != -1) {
        Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
        return;
      }

      var soup = Beautifulsoup(res.body);
      final inputs = soup.find_all("input").map((e) => e.attributes).toList();
      List academicTerms =
          soup.find_all("option").map((e) => e.text.trim()).toSet().toList();

      inputs.forEach((element) {
        // Populate form data
        if (formData[element["name"]] == "") {
          formData[element["name"]] =
              (element["value"] == "Clear" || element["value"] == null)
                  ? ""
                  : element["value"];
        }
      });

      formData["ctl00\$mainContent\$DDLACADEMICTERM"] = academicTerm;

      return academicTerms;
    } else {
      formData["ctl00\$mainContent\$DDLACADEMICTERM"] = academicTerm.toString();
      Response res = await client.post("$hostname$internalsURL",
          headers: headers, body: formData);

      var soup = Beautifulsoup(res.body);
      List table = soup.find_all("tr").map((e) => e.innerHtml).toSet().toList();

      bool flagReached = false;
      Map data = new Map();
      table.forEach((element) {
        if (element.indexOf("Entered by") != -1) {
          flagReached = true;
          return;
        }
        if (flagReached) {
          element = element.trim().replaceAll("<td>", "");
          element = element.trim().replaceAll("</td>", "<space>");
          
          data[element.split("<space>")[8]] = element.split("<space>");
          data[element.split("<space>")[8]].removeWhere((element) => element == "");
        }
      });

      return (res.body.indexOf("No records to display.") != -1)
          ? "No records to display."
          : Map.of(data);
    }
  }

  Future<Map> parse() async {
    // Parse basic info
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
    // Getter method for basic info
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
