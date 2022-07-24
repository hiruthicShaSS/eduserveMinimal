import 'dart:convert';

import 'package:eduserveMinimal/global/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/service/network_service.dart';

class AuthService {
  static Map<String, String> headers = {};
  static Map<String, String> formData = {};
  static String? cookie;
  NetworkService _networkService = NetworkService();

  Future<Map<String, String>> basicFormData([String? htmlPage]) async {
    Document html;

    if (htmlPage == null) {
      Response res =
          await _networkService.get(Uri.parse("https://eduserve.karunya.edu"));
      html = Document.html(res.body);
    } else {
      html = Document.html(htmlPage);
    }

    Map<String, String> data = {};

    List inputs = html
        .querySelectorAll("input")
        .map((e) => {e.attributes["name"]: e.attributes["value"]})
        .toList();

    inputs.removeWhere((element) =>
        element.keys.first == null || element.values.first == null);

    for (var input in inputs) {
      data[input.keys.first!] = input.values.first;
    }

    List<String> radScriptmanagerHtml = html
        .querySelectorAll("script")
        .where((element) =>
            element.attributes["src"]?.contains("RadScriptManager1") ?? false)
        .map((e) => e.attributes["src"] ?? "")
        .toList();

    if (radScriptmanagerHtml.isNotEmpty) {
      String radScriptManager = radScriptmanagerHtml.first.split("=").last;

      data["RadScriptManager1_TSM"] = Uri.decodeFull(radScriptManager);
    }

    return data;
  }

  Future<String> login({
    String? username,
    String? password,
    bool update = false,
    Function? callback,
  }) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();

    if (!update) {
      username = await storage.read(key: "username");
      password = await storage.read(key: "password");
    }

    Map<String?, String?>? login_data = {
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
    Response res = await _networkService.get(Uri.parse(
        "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx"));
    String eduserveCookie = res.headers["set-cookie"]!;

    Document html = Document.html(res.body);

    List inputs = html
        .querySelectorAll("input")
        .map((e) => {e.attributes["name"]: e.attributes["value"]})
        .toList();

    inputs.removeWhere((element) =>
        element.keys.first == null || element.values.first == null);

    for (var input in inputs) {
      login_data[input.keys.first!] = input.values.first;
    }

    // Get login.aspx
    headers["cookie"] = eduserveCookie.split(";")[0];
    headers["referer"] =
        "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx";

    // Post to login.aspx
    res = await _networkService.post(
      Uri.parse(
          "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx"),
      headers: headers,
      body: login_data,
    );

    if (res.body.indexOf(
            "Your login attempt was not successful. Please try again.") !=
        -1) {
      throw LoginError(
          "Your login attempt was not successful. Please try again.");
    }

    if (res.statusCode == 302) {
      headers["cookie"] = cookie ??
          headers["cookie"]! + "; ${res.headers['set-cookie']!.split(';')[0]}";
      res = await _networkService.get(
          Uri.parse("https://eduserve.karunya.edu${res.headers["location"]}"),
          headers: headers);
    }

    if (res.body.contains("Hourly Feedback")) {
      throw FeedbackFormFound("Feedback form found!");
    }

    await storage.write(key: "headers", value: jsonEncode(headers));
    await storage.write(
        key: "header_lastWrite",
        value: DateTime.now().millisecondsSinceEpoch.toString());

    return res.body;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FlutterSecureStorage storage = FlutterSecureStorage();

    await storage.delete(key: "username");
    await storage.delete(key: "password");
    await storage.delete(key: kStorage_key_lastAttendancePercent);
    await storage.delete(key: kStorage_key_timetableData);
    await storage.delete(key: kStorage_key_userData);
    await prefs.remove("autoFillFeedbackValue");
    await prefs.remove(kPrefs_key_timeTableLastUpdate);
    await prefs.remove(kPrefs_key_userLastUpdate);

    await QuickActions().clearShortcutItems();
  }

  Future forgotPassrword(String username, String dob, String kmail) async {
    List<String> possibleErrors = [
      "Enter the Student Register No.",
      "Enter the Date of Birth",
      "Enter the official email ID",
    ];

    Response res = await _networkService.get(
      Uri.parse("https://eduserve.karunya.edu/Online/PasswordReset.aspx"),
      headers: headers,
    );

    Map formDataForPasswordReset = await basicFormData(res.body);

    formDataForPasswordReset[r"__EVENTTARGET"] =
        r"ctl00$mainContent$RBLPASSWORD$1";
    formDataForPasswordReset["__EVENTARGUMENT"] = "";
    formDataForPasswordReset["__LASTFOCUS"] = "";
    formDataForPasswordReset[r"ctl00$mainContent$RBLPASSWORD"] = "2";

    formDataForPasswordReset.remove(r"ctl00$mainContent$Login1$LoginButton");

    res = await post(
      Uri.parse("https://eduserve.karunya.edu/Online/PasswordReset.aspx"),
      headers: headers,
      body: formDataForPasswordReset,
    );

    formDataForPasswordReset.addAll(await basicFormData(res.body));

    formDataForPasswordReset[r"ctl00$mainContent$TXTSTUDUSERID"] = username;
    formDataForPasswordReset[r"ctl00$mainContent$TXTSTUDDOB"] = dob;
    formDataForPasswordReset[r"ctl00$mainContent$TXTSTUDEMAIL"] = kmail;
    formDataForPasswordReset[r"ctl00$mainContent$btnStudReset"] =
        "Reset Password";

    formDataForPasswordReset["__EVENTTARGET"] = "";

    res = await post(
      Uri.parse("https://eduserve.karunya.edu/Online/PasswordReset.aspx"),
      headers: headers,
      body: formDataForPasswordReset,
    );

    // Document html = Document.html(res.body);
    // List<String> webResources = html
    //     .querySelectorAll("script")
    //     .map((e) => e.attributes["src"] ?? "")
    //     .where((e) => e.contains("ScriptResource") || e.contains("WebResource"))
    //     .toList();

    // for (var resource in webResources) {
    //   await _networkService.get(
    //     Uri.parse("https://eduserve.karunya.edu$resource"),
    //     headers: headers,
    //   );
    // }

    print(res.body);

    print(res.body.contains("Password Reset Successfully"));

    return res.body;
  }
}
