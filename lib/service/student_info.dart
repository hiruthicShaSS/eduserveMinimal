// 📦 Package imports:
import 'dart:convert';

import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/scrap.dart';

Future<User> getStudentInfo() async {
  String studentHomePage = await AuthService().login();

  if (studentHomePage == "") return User();

  Document html = Document.html(studentHomePage);

  String? studentImage =
      html.querySelector("#mainContent_IMGSTUDENT")?.attributes["src"];

  User user = User(
    registerNumber:
        html.querySelector("#mainContent_LBLREGNO")?.innerHtml ?? "",
    kmail: html.querySelector("#mainContent_LBLEMAILID")?.innerHtml ?? "",
    name: html.querySelector("#mainContent_LBLNAME")?.innerHtml ?? "",
    mobile: html.querySelector("#mainContent_LBLMOBILENO")?.innerHtml ?? "",
    programme: html.querySelector("#mainContent_LBLPROGRAMME")?.innerHtml ?? "",
    mentor: html.querySelector("#mainContent_LBLMENTOR")?.innerHtml ?? "",
    semester: int.parse(
        html.querySelector("#mainContent_LBLSEMESTER")?.innerHtml ?? "0"),
    attendance: double.parse(
        html.querySelector("#mainContent_LBLCLASS")?.text.replaceAll("%", "") ??
            "0"),
    assemblyAttendance: double.parse(html
            .querySelector("#mainContent_LBLASSEMBLY")
            ?.text
            .replaceAll("%", "") ??
        "0"),
    cgpa: double.parse(
        html.querySelector("#mainContent_LBLCURRENTCGPA")?.text ?? "0"),
    sgpa: double.parse(
        html.querySelector("#mainContent_LBLCURRENTSGPA")?.text ?? "0"),
    arrears:
        int.parse(html.querySelector("#mainContent_LBLARREAR")?.text ?? "0"),
    resultOf:
        html.querySelector("#mainContent_LBLCURRENTMONTHYR")?.text.trim() ?? "",
    credits: double.parse(
        html.querySelector("#mainContent_LBLCURRENTCREDITEARNED")?.text ?? "0"),
    nonAcademicCredits: double.parse(html
            .querySelector("#mainContent_LBLCURRENTNONACADEMICCREDITEARNED")
            ?.text ??
        "0"),
  );

  Response imageResponse = await get(
    Uri.parse(
        "https://eduserve.karunya.edu/${studentImage?.replaceAll("../", "")}"),
    headers: AuthService.headers,
  );
  user.image = imageResponse.bodyBytes;

  Scraper.cache["user"] = user.toMap();

  final FlutterSecureStorage storage = FlutterSecureStorage();
  await storage.write(key: "userData", value: jsonEncode(user.toMap()));

  return user;
}
