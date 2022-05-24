import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eduserveMinimal/service/scrap.dart';

class AuthService {
  static Map<String, String> headers = {};
  static Map<String, String> formData = {};

  Future<String> login(
      {String? username, String? password, Function? callback}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    username = prefs.getString("username") ?? username;
    password = prefs.getString("password") ?? password;

    var connection = await (Connectivity().checkConnectivity());
    if (connection == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "Internet, caveman. Turn it on...",
        timeInSecForIosWeb: 10,
      );
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
    var res = await get(Uri.parse(
        "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx"));
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
    headers["cookie"] = eduserveCookie.split(";")[0];
    headers["referer"] =
        "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx";

    // Post to login.aspx
    res = await post(
      Uri.parse(
          "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx"),
      headers: headers,
      body: login_data,
    );

    if (res.body.indexOf(
            "Your login attempt was not successful. Please try again.") !=
        -1) {
      Fluttertoast.showToast(
          msg: "Your login attempt was not successful. Please try again.",
          gravity: ToastGravity.CENTER);

      return "Login error";
    }

    if (res.statusCode == 302) {
      headers["cookie"] =
          headers["cookie"]! + "; ${res.headers['set-cookie']!.split(';')[0]}";
      res = await get(
          Uri.parse("https://eduserve.karunya.edu${res.headers["location"]}"),
          headers: headers);
    }

    if (res.body.contains("Hourly Feedback")) {
      return "feedback form found";
    }

    Scraper.cache["home"] = res.body;

    return res.body;
  }
}
