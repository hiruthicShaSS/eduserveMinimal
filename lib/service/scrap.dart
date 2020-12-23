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

// Request on /:
// "cookie: ASP.NET_SessionId=4kgjcbdm5aj4jirzrn13axn3; .ASPXAUTH=AF2E3E04139BF16180E27AFC85529AB27E00B725372C66B20DE762C75F8DDDAA8950DAD858D3AE9A0487CB75FDC3343B7AEC10DB4028F4C49A37C8806B523BC975B9D0E1DC0954ADBFEF8D1002F9699FBC11CEBEECFBE89DFEC849EE8C313A52BC5C11FC"

// Response on login.aspx:
// "set-cookie: .ASPXAUTH=AF2E3E04139BF16180E27AFC85529AB27E00B725372C66B20DE762C75F8DDDAA8950DAD858D3AE9A0487CB75FDC3343B7AEC10DB4028F4C49A37C8806B523BC975B9D0E1DC0954ADBFEF8D1002F9699FBC11CEBEECFBE89DFEC849EE8C313A52BC5C11FC; path=/; secure; HttpOnly; SameSite=Lax"

// Request to login [POST]:
// "ookie: ASP.NET_SessionId=4kgjcbdm5aj4jirzrn13axn3; .ASPXAUTH=EDC6E8F6DAAE0EE5871CB47A3C7B6A132ED571C9228C79A966D9EEC7DFD214342AFA53B41AB56B42D3896B60A50564F376F3089FBD496037FBEDE86B0EEFC2494B2C6792187B1B97417B10DE9E5F6A8B2684982701ED4A03178AEFD9052BB5DA5F2FDB90"

// Request to home.aspx [GET]:
// cookie: ASP.NET_SessionId=4kgjcbdm5aj4jirzrn13axn3; .ASPXAUTH=AF2E3E04139BF16180E27AFC85529AB27E00B725372C66B20DE762C75F8DDDAA8950DAD858D3AE9A0487CB75FDC3343B7AEC10DB4028F4C49A37C8806B523BC975B9D0E1DC0954ADBFEF8D1002F9699FBC11CEBEECFBE89DFEC849EE8C313A52BC5C11FC
