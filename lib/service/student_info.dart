// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/service/auth.dart';
import 'package:eduserveMinimal/service/network_service.dart';

Future<User> getStudentInfo() async {
  NetworkService _networkService = NetworkService();

  Response res = await _networkService.get(
    Uri.parse("https://eduserve.karunya.edu/Student/Home.aspx"),
    headers: AuthService.headers,
  );

  if (res.body.indexOf("Login") != -1) {
    await AuthService().login();
  }

  Document html = Document.html(res.body);

  String? studentImage =
      html.querySelector("#mainContent_IMGSTUDENT")?.attributes["src"];
  String? qrImage =
      html.querySelector("#mainContent_IMGQRCode")?.attributes["src"];

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

  Response imageResponse = await _networkService.get(
    Uri.parse(
        "https://eduserve.karunya.edu/${studentImage?.replaceAll("../", "")}"),
    headers: AuthService.headers,
  );
  user.image = imageResponse.bodyBytes;
  imageResponse = await _networkService.get(
    Uri.parse("https://eduserve.karunya.edu/${qrImage?.replaceAll("../", "")}"),
    headers: AuthService.headers,
  );
  user.qrCode = imageResponse.bodyBytes;

  final FlutterSecureStorage storage = FlutterSecureStorage();
  await storage.write(key: "userData", value: jsonEncode(user.toMap()));

  return user;
}
