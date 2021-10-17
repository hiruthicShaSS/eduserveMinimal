// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Scraper {
  static BuildContext? mainPageContext;
  static String status = "";
  late SharedPreferences prefs;
  late Client client;
  Map pages = {};
  String hostname = "https://eduserve.karunya.edu";
  String url = "";
  Map cache = {};

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

  Future<Map> fetchAllData() async {
    await this.getFeesDetails();
    await this.getInfo();
    List? hallTicketData = await this.downloadHallTicket();
    if (hallTicketData != null) {
      await this.downloadHallTicket(
          term: hallTicketData[1].values.toList()[0]["value"]);
    }

    return cache;
  }

  int totalFeedback = 0;

  Future<List> getFeedbackForm([int? stars]) async {
    Response page = await client.get(
        Uri.parse("https://eduserve.karunya.edu/MIS/IQAC/HFBCollection.aspx"),
        headers: headers);

    pages["hfb"] = page;

    Beautifulsoup feedbackSoup = Beautifulsoup(page.body);
    List feedbackList =
        feedbackSoup.find_all("td").map((e) => e.text.trim()).toList();

    List feedback = [];
    List allFeedback = [];
    bool feedbackStart = false;
    feedbackList.forEach((element) {
      if (element == "Class Not Handled") {
        feedback.removeWhere((element) => element == "");
        allFeedback.add(feedback);
        feedbackStart = false;
        feedback = [];

        return;
      }

      if (element.toString().contains("Command item")) {
        feedbackStart = true;
        return;
      }

      feedback.add(element.toString().trim());
    });

    totalFeedback = allFeedback.length;
    return allFeedback;
  }

  Future<void> fillFeedbackForm(Map rating) async {
    Map feedback_data = formData;

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

  Future<String> login(
      [String? username, String? password, Function? callback]) async {
    // Login
    var connection = await (Connectivity().checkConnectivity());
    if (connection == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "Internet, caveman. Turn it on...",
        timeInSecForIosWeb: 10,
      );
    }

    String loginAddress = "/Login.aspx?ReturnUrl=%2f";

    Map<String?, String?>? login_data = {
      "RadScriptManager1_TSM": "",
      "__EVENTTARGET": "",
      "__EVENTARGUMENT": "",
      "__VIEWSTATE": "",
      "__VIEWSTATEGENERATOR": "",
      "__EVENTVALIDATION": "",
      "ctl00\$mainContent\$Login1\$UserName":
          prefs.getString("username") ?? username,
      "ctl00\$mainContent\$Login1\$Password":
          prefs.getString("password") ?? password,
      "ctl00\$mainContent\$Login1\$LoginButton": "Log In"
    };

    status = "Get EduServe...";

    // Get karunya.edu
    url = hostname;
    headers["referer"] = url;
    var res = await client.get(Uri.parse(url));
    var eduserveCookie =
        res.headers["set-cookie"]!; // Set the ASP.NET_SessionId

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
    res = await client.post(Uri.parse(url), headers: headers, body: login_data);

    if (res.body.indexOf(
            "Your login attempt was not successful. Please try again.") !=
        -1) {
      Fluttertoast.showToast(
          msg: "Your login attempt was not successful. Please try again.",
          gravity: ToastGravity.CENTER);

      return "Login error";
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

  Future<List> getAttendance() async {
    Response page = await client.get(
        Uri.parse("https://eduserve.karunya.edu/Student/Home.aspx"),
        headers: headers);
    pages["home"] = page;

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

    return attendenceList;
  }

  Future<Map<String, List<List<String>>>> getLeaveInfo() async {
    Map<String, List<List<String>>> parsePage(Response page) {
      String onDutySection =
          pages["home"].body.toString().split("Leave Type")[1];

      Beautifulsoup onDutySoup = Beautifulsoup(onDutySection);
      List onDuties = onDutySoup.find_all("td").map((e) => e.text).toList();

      Beautifulsoup leaveSoup = Beautifulsoup(page.body.toString());
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

      return {"onDuty": allOnDuty, "leave": allLeave};
    }

    if (pages.keys.contains("home")) return parsePage(pages["home"]);

    Response home_page = await client.get(
        Uri.parse("https://eduserve.karunya.edu/Student/Home.aspx"),
        headers: headers);
    pages["home"] = home_page;
    return parsePage(home_page);
  }

  Future<Map?> getFeesDetails({bool force = false}) async {
    if (cache.containsKey("fees")) return cache["fees"];

    String feesDownload = "/Student/Fees/DownloadReceipt.aspx";
    String feesOverallStatement = "/Student/Fees/FeesStatement.aspx";
    Map feesStatement = new Map();

    Response page = await client.get(Uri.parse("$hostname${feesDownload}"),
        headers: headers);

    if (page.body.indexOf("Login") != -1) {
      Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
      return null;
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

        List? temp = [];
        temp = element.split("<space>");
        temp!.removeRange(0, 3);
        temp.removeWhere((element) => element.length == 0);
        feesStatement[temp[1]] = temp;
      }
    });

    feesStatement["dues"] = dueslist;
    cache["fees"] = feesStatement;
    return feesStatement;
  }

  Future<Map?> getTimetable({bool force = false}) async {
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
    Response res =
        await client.get(Uri.parse("$hostname$timetableURL"), headers: headers);

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

    await timetableFile.writeAsString(jsonEncode(data));

    return data;
  }

  Future<List?> downloadHallTicket(
      {String? term, bool download = false}) async {
    final String hallticketURL = "/Student/CBCS/HallTicketDownload.aspx";

    if (term == null) {
      Response res = await client.get(Uri.parse("$hostname$hallticketURL"),
          headers: headers);
      if (res.body.indexOf("Login") != -1) {
        Fluttertoast.showToast(msg: "esM: Session expired. Refresh data!");
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
        Map formDataCopy = formData;
        Map headersCopy = headers;

        headersCopy["referer"] =
            "https://eduserve.karunya.edu/Student/CBCS/HallTicketDownload.aspx";
        headersCopy["Sec-Fetch-Dest"] = "document";
        headersCopy["sec-ch-ua"] = ';Not A Brand";v="99", "Chromium";v="94"';
        headersCopy["sec-ch-ua-mobile"] = "?0";
        headersCopy["sec-ch-ua-platform"] = "Windows";
        headersCopy["sec-fetch-dest"] = "document";
        headersCopy["sec-fetch-mode"] = "navigate";
        headersCopy["sec-fetch-site"] = "same-origin";
        headersCopy["sec-fetch-user"] = "?1";

        formDataCopy["ctl00\$mainContent\$BTNDOWNLOAD"] = "Download";
        formDataCopy["__EVENTTARGET"] = "";
        formDataCopy.remove("ctl00\$mainContent\$DDLACADEMICTERM");
        Response res = await client.post(Uri.parse("$hostname$hallticketURL"),
            headers: headersCopy as Map<String, String>?, body: formDataCopy);

        print(res.headers);
        return [];
      }

      if (cache.containsKey("hallticket")) return cache["hallticket"];

      headers["ctl00\$mainContent\$DDLACADEMICTERM"] = "";
      Response res = await client.post(Uri.parse("$hostname$hallticketURL"),
          headers: headers, body: formData);

      Beautifulsoup hallticketSoup = Beautifulsoup(res.body);
      List eligibility =
          hallticketSoup.find_all("td").map((e) => e.text.trim()).toList();

      List endFlag = eligibility.map((e) => e.length > 80 ? e : null).toList();
      endFlag.removeWhere((element) => element == null);
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

      cache["hallticket"] = [mainEligibility, allEligibility];
      return [mainEligibility, allEligibility];
    }
  }

  Future getInternalMarks({String? academicTerm = null}) async {
    final String internalsURL = "/Student/InternalMarks.aspx";

    if (academicTerm == null) {
      Response res = await client.get(Uri.parse("$hostname$internalsURL"),
          headers: headers);

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
      Map formDataCopy = formData;
      formDataCopy["ctl00\$mainContent\$DDLACADEMICTERM"] =
          academicTerm.toString();
      Response res = await client.post(Uri.parse("$hostname$internalsURL"),
          headers: headers, body: formDataCopy);

      if ((res.body.indexOf("No records to display.") != -1)) {
        return "No records to display.";
      }

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
          data[element.split("<space>")[8]]
              .removeWhere((element) => element == "");
        }
      });

      return Map.of(data);
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
    String? studentImage =
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
          // if onDuty applications found set the flag to true.
          flagReached = true;
        }

        if (flagReached) {
          // Wait untill the onDuty applications found.
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
    if (cache.containsKey("user")) return cache["user"];

    Map data = await parse();
    data["dateScraped"] = DateTime.now().toString();
    cache["user"] = data;
    return data;
  }
}
