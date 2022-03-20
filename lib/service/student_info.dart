// 📦 Package imports:
import 'dart:convert';

import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/service/login.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<User> getInfo() async {
  String studentHomePage = await login();

  if (studentHomePage == "") return User();

  var soup = Beautifulsoup(studentHomePage);
  List<String?> basicInfo =
      soup.find_all("span").map((e) => (e.innerHtml)).toList().sublist(53);
  String? studentImage =
      soup.find_all("img").map((e) => (e.attributes["src"])).toList()[2];
  String? qrImage =
      soup.find_all("img").map((e) => (e.attributes["src"])).toList()[3];
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
          List splited =
              temp.split("<space>"); // Once completed parse the string to list.
          splited.removeWhere((element) => RegExp(r"\d{5,}").hasMatch(element));
          splited.asMap().forEach((i, value) {
            splited[i] = splited[i].trim();
          });
          splited.removeWhere(
              (element) => element.toString() == ""); // Remove empty elements.
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
  basicInfo.add(qrImage);
  basicInfo.removeWhere(
      (element) => element.toString() == ""); // Remove empty elements
  basicInfo.remove("Academic Performance Summary");

  User user = User(
    registerNumber: basicInfo[0],
    kmail: basicInfo[1],
    name: basicInfo[2],
    mobile: basicInfo[3],
    programme: basicInfo[4],
    mentor: basicInfo[5],
    semester: int.parse(basicInfo[6] ?? "0"),
    attendance: double.parse(basicInfo[7]?.replaceAll("%", "") ?? "0"),
    assemblyAttendance: double.parse(basicInfo[8]?.replaceAll("%", "") ?? "0"),
    cgpa: double.parse(basicInfo[9] ?? "0"),
    sgpa: double.parse(basicInfo[14] ?? "0"),
    arrears: int.parse(basicInfo[10] ?? "0"),
    resultOf: basicInfo[11],
    credits: double.parse(basicInfo[12] ?? "0"),
    nonAcademicCredits: double.parse(basicInfo[15] ?? "0"),
  );

  user.leaveApplications = leaveApplication;

  Response imageResponse = await get(
      Uri.parse(
          "https://eduserve.karunya.edu/${basicInfo[16]?.replaceAll("../", "")}"),
      headers: httpHeaders);
  user.image = imageResponse.bodyBytes;
  Response qrCodeResponse = await get(
      Uri.parse(
          "https://eduserve.karunya.edu/${basicInfo[17]?.replaceAll("../", "")}"),
      headers: httpHeaders);
  user.qrCode = qrCodeResponse.bodyBytes;

  Scraper.cache["user"] = user.toMap();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("userData", jsonEncode(user.toMap()));

  return user;
}
