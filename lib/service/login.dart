// Package imports:
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:connectivity/connectivity.dart';
import 'package:eduserveMinimal/service/scrap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:eduserveMinimal/global/gloabls.dart';
import 'package:eduserveMinimal/providers/app_state.dart';

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

  Map<String?, String?>? login_data = {
    "RadScriptManager1_TSM": "",
    "__EVENTTARGET": "",
    "__EVENTARGUMENT": "",
    "__VIEWSTATE": "",
    "__VIEWSTATEGENERATOR": "",
    "__EVENTVALIDATION": "",
    "ctl00\$mainContent\$Login1\$UserName":
        AppState.prefs!.getString("username") ?? username,
    "ctl00\$mainContent\$Login1\$Password":
        AppState.prefs!.getString("password") ?? password,
    "ctl00\$mainContent\$Login1\$LoginButton": "Log In"
  };
  var res = await http.get(Uri.parse(
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx"));
  var eduserveCookie = res.headers["set-cookie"]!; // Set the ASP.NET_SessionId

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
  httpHeaders["cookie"] = eduserveCookie.split(";")[0];
  httpHeaders["referer"] =
      "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx";

  // Post to login.aspx
  res = await http.post(
      Uri.parse(
          "https://eduserve.karunya.edu/Login.aspx?ReturnUrl=%2fStudent%2fAttSummary.aspx"),
      headers: httpHeaders,
      body: login_data);

  if (res.body.indexOf(
          "Your login attempt was not successful. Please try again.") !=
      -1) {
    Fluttertoast.showToast(
        msg: "Your login attempt was not successful. Please try again.",
        gravity: ToastGravity.CENTER);

    return "Login error";
  }

  if (res.statusCode == 302) {
    httpHeaders["cookie"] = httpHeaders["cookie"]! +
        "; ${res.headers['set-cookie']!.split(';')[0]}";
    res = await http.get(
        Uri.parse("https://eduserve.karunya.edu${res.headers["location"]}"),
        headers: httpHeaders);
  }

  if (res.body.contains("Hourly Feedback")) {
    return "feedback form found";
  }

  Scraper.cache["home"] = res.body;

  return res.body;
}
